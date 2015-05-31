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
    rc = if a_bit == "1" then "M" else "A" end
    st = comp_tokens.map{|x| x.value}.join
    c_bits = case st
             when "0"
               "101010"
             when "1"
               "111111"
             when "-1"
               "111010"
             when "D"
               "001100"
             when rc
               "110000"
             when "!D"
               "001101"
             when "!#{rc}"
               "110001"
             when "-D"
               "001111"
             when "-#{rc}"
               "110011"
             when "D+1"
               "011111"
             when "#{rc}+1"
               "110111"
             when "D-1"
               "001110"
             when "#{rc}-1"
               "110010"
             when "D+#{rc}"
               "000010"
             when "D-#{rc}"
               "010011"
             when "#{rc}-D"
               "000111"
             when "D&#{rc}"
               "000000"
             when "D|#{rc}"
               "010101"
             else
               raise "error translating comp_bits for #{st}"
             end
    "#{a_bit}#{c_bits}"
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
