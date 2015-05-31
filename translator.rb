require './instruction.rb'
require './token.rb'

class AInstruction
  def translate(symbol_table)
    return "0#{fill_z(addr.number.to_s(2), 15)}" if addr.is_a? TokenNumber
    symbol = addr.symbol
    "0#{fill_z(symbol_table[symbol].to_s(2), 15)}"
  end

  def fill_z(st, len)
    "0"*(len - st.length) + st
  end
end

class CInstruction
  def translate(symbol_table)
    "111#{comp_bits}#{dest_bits}#{jump_bits}"
  end

  def comp_bits
    a_bit = b2s(comp_tokens.any? {|x| x.is_a?(TokenSymbol) && x.symbol == "M"})
    c = case comp_tokens.length
        when 1
          comp_single_token
        when 2
          comp_double_tokens
        when 3
          comp_triple_tokens
        else
          raise "comp tokens number larger than 3"
        end
    "#{a_bit}#{c}"
  end

  def comp_single_token
    token = comp_tokens.first
    if token.is_a? TokenNumber
      if token.number == 0 then "101010" else "111111" end
    else
      if token.symbol == "D" then "001100" else "110000" end
    end
  end

  def comp_double_tokens
    token = comp_tokens.last
    if comp_tokens.first.is_a? TokenNot
      if token.symbol == "D" then "001101" else "110001" end
    else
      if token.is_a? TokenNumber
        "111010"
      else
        if token.symbol == "D" then "001111" else "110011" end
      end
    end
  end

  def comp_triple_tokens
    mid = comp_tokens[1]
    return "000000" if mid.is_a? TokenAnd #D&A
    return "010101" if mid.is_a? TokenOr #D|A
    if mid.is_a? TokenAdd
      return "110111" if comp_tokens.first.symbol == "A"  #A+1
      return "011111" if comp_tokens.last.is_a? TokenNumber #D+1
      return "000010" #D+A
    else
      if comp_tokens.first.symbol == "D"
        return "001110" if comp_tokens.last.is_a? TokenNumber #D-1
        return "010011" #D-A
      else
        return "110010" if comp_tokens.last.is_a? TokenNumber #A-1
        return "000111" #A-D
      end
    end
  end

  def dest_bits
    return "000" if dest_symbol.nil?
    symbol = dest_symbol.symbol
    high = b2s(symbol.include?("A"))
    mid = b2s(symbol.include?("D"))
    low = b2s(symbol.include?("M"))
    return "#{high}#{mid}#{low}"
  end

  def b2s(x)
    if x then "1" else "0" end
  end

  def jump_bits
    case jump_symbol
    when nil
      "000"
    when "JGT"
      "001"
    when "JEQ"
      "010"
    when "JGE"
      "011"
    when "JLT"
      "100"
    when "JNE"
      "101"
    when "JLE"
      "110"
    when "JMP"
      "111"
    end
  end
end

class Translator

  def init
    @symbol_table = {}
  end

  def translate(instructions)
    init
    first_pass instructions
    second_pass instructions
    third_pass instructions
  end

  def first_pass(instructions)
    idx_without = 0
    instructions.each do |ins|
      if ins.is_a? LabelInstruction
        @symbol_table[ins.label] = idx_without + 1
      else
        idx_without += 1
      end
    end
  end

  def second_pass(instructions)
    idx = 16
    instructions.each do |ins|
      if ins.is_a?(AInstruction) && ins.addr.is_a?(TokenSymbol)
        symbol = ins.addr.symbol
        unless @symbol_table.includes? symbol
          @symbol_table[symbol] = idx
          idx += 1
        end
      end
    end
  end

  def third_pass(instructions)
    ret = []
    instructions.each do |ins|
      next if ins.is_a? LabelInstruction
      ret << ins.translate(@symbol_table)
    end
    ret
  end
end