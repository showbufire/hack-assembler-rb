require './token.rb'
require './instruction.rb'

class Parser
  def parse(tokens)
    if tokens.first.is_a? TokenAt
      error(tokens) unless tokens.length == 2
      return AInstruction.new(tokens.last)
    end
    if tokens.first.is_a? TokenLeftParen
      error(tokens) unless tokens.lenght = 3;
      return LabelInstruction.new(token[1]);
    end

    parse_cinstruction(tokens)
  end

  def parse_cinstruction(tokens)
    dest_symbol = nil
    start_idx = 0
    if tokens[1].is_a? TokenAssign
      dest_symbol = tokens[0]
      start_idx = 2;
    end
    
    jump_symbol = nil
    end_idx = tokens.length - 1
    if tokens[-2].is_a? TokenSemiColon
      jump_symbol = tokens[-1]
      end_idx = tokens.length - 3;
    end
    
    error(tokens) unless start_idx <= end_idx
    CInstruction.new dest_symbol, tokens[start_idx, end_idx], jump_symbol
  end

  def error(tokens)
    raise "error parsing #{tokens}"
  end
end
