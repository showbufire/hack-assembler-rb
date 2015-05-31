require './token.rb'

class Instruction
end

class AInstruction < Instruction
  attr_reader :addr
  
  def initialize(addr)
    @addr = addr
  end

  def lineno
    @addr.lineno
  end

  def to_s
    "AInstruction at line #{lineno}"
  end
end

class CInstruction < Instruction
  attr_reader :dest_symbol, :comp_tokens, :jump_symbol
  
  def initialize(dest_symbol, comp_tokens, jump_symbol)
    @dest_symbol = dest_symbol
    @comp_tokens = comp_tokens
    @jump_symbol = jump_symbol
  end

  def lineno
    @comp_tokens[0].lineno if @comp_tokens.length > 0
  end

  def to_s
    "CInstruction at line #{lineno}"
  end
end

class LabelInstruction < Instruction
  attr_reader :label
  
  def initialize(label)
    @label = label
  end
end
