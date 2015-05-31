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
    a_bit = b2s(comp_tokens.any? {|x| x.is_msym?})
    c = case comp_tokens.length
        when 1
          comp_single_token
        when 2
          comp_double_tokens
        when 3
          comp_triple_tokens
        else
          raise "comp tokens number is not 1 or 2 or 3 at line #{lineno}}"
        end
    "#{a_bit}#{c}"
  end

  def comp_single_token
    token = comp_tokens.first
    if token.is_a? TokenNumber
      if token.number == 0 then "101010" else "111111" end
    else
      if token.is_dsym? then "001100" else "110000" end
    end
  end

  def comp_double_tokens
    token = comp_tokens.last
    if comp_tokens.first.is_a? TokenNot
      if token.is_dsym? then "001101" else "110001" end
    else
      if token.is_a? TokenNumber
        "111010"
      else
        if token.is_dsym? then "001111" else "110011" end
      end
    end
  end

  def comp_triple_tokens
    mid = comp_tokens[1]
    return "000000" if mid.is_a? TokenAnd #D&A
    return "010101" if mid.is_a? TokenOr #D|A
    if mid.is_a? TokenAdd
      return "110111" if comp_tokens.first.symbol != "D"  #A+1
      return "011111" if comp_tokens.last.is_a? TokenNumber #D+1
      return "000010" #D+A
    else
      if comp_tokens.first.is_dsym?
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
    return "000" if jump_symbol.nil?
    case jump_symbol.symbol
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
    else
      raise "unknow jump symbol #{jump_symbol.symbol}"
    end
  end
end

class Translator

  attr_reader :symbol_table

  def init
    @symbol_table = {
      "SP" => 0,
      "LCL" => 1,
      "ARG" => 2,
      "THIS" => 3,
      "THAT" => 4,
      "SCREEN" => 16384,
      "KBD" => 24576
    }
    0.upto(15).each {|x| @symbol_table["R#{x}"]=x}
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
        @symbol_table[ins.label.symbol] = idx_without
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
        unless @symbol_table.include?(symbol)
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
