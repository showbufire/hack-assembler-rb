class Token
  attr_reader :lineno
  def initialize(lineno)
    @lineno = lineno
  end

  def is_msym?
    false
  end

  def is_asym?
    false
  end

  def is_dsym?
    false
  end

  def to_s
    "#{self.class}(#{value}) @#{lineno}"
  end
end

class TokenAt < Token
  def value
    "@"
  end
end

class TokenSemiColon < Token
  def value
    ";"
  end
end

class TokenLeftParen < Token
  def value
    "("
  end
end

class TokenRightParen < Token
  def value
    ")"
  end
end

class TokenAssign < Token
  def value
    "="
  end
end

class TokenMinus < Token
  def value
    "-"
  end
end

class TokenAdd < Token
  def value
    "+"
  end
end

class TokenNot < Token
  def value
    "!"
  end
end

class TokenAnd < Token
  def value
    "&"
  end
end

class TokenOr < Token
  def value
    "|"
  end
end

class TokenSymbol < Token
  attr_reader :symbol

  alias value symbol
  
  def initialize(symbol, lineno)
    super(lineno)
    @symbol = symbol
  end
  
  def is_dsym?
    symbol == "D"
  end

  def is_asym?
    symbol == "A"
  end

  def is_msym?
    symbol == "M"
  end
end

class TokenNumber < Token
  attr_reader :number

  def initialize(number, lineno)
    super(lineno)
    @number = number
  end

  def value
    number.to_s
  end
end
