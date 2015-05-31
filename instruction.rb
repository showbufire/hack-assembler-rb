require './token.rb'

class Instruction
  include Enumerable
  
  def to_s
    children = map{|x| x.value}
    "#{self.class} @#{lineno} [#{children.join(",")}]"
  end

  def each(&block)
    to_enum :tokens if block.nil?
    tokens(&block)
  end

  def lineno
    first.lineno
  end
end

class AInstruction < Instruction
  attr_reader :addr

  def initialize(addr)
    @addr = addr
  end

  def tokens
    yield addr
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

  def tokens
    yield dest_symbol unless dest_symbol.nil?
    comp_tokens.each {|token| yield token}
    yield jump_symbol unless jump_symbol.nil?
  end
end

class LabelInstruction < Instruction
  attr_reader :label
  
  def initialize(label)
    @label = label
  end

  def tokens
    yield label
  end
end
