class Token
  attr_reader :lineno
  def initialize(lineno)
    @lineno = lineno
  end
end

class TokenAt < Token
end

class TokenSemiColon < Token
end

class TokenLeftParen < Token
end

class TokenRightParen < Token
end

class TokenAssign < Token
end

class TokenMinus < Token
end

class TokenAdd < Token
end

class TokenNot < Token
end

class TokenAnd < Token
end

class TokenOr < Token
end

class TokenSymbol < Token
  attr_reader :symbol
  
  def initialize(symbol, lineno)
    super(lineno)
    @symbol = symbol
  end

  def to_s
    "Symbol: #{@symbol}"
  end
end

class TokenNumber < Token
  attr_reader :number

  def initialize(number, lineno)
    super(lineno)
    @number = number
  end

  def to_s
    "Number: #{@number}"
  end
end
