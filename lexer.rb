##
## symbols:
## @ ; ( ) = - + ! & |
## label: char+(char | number | _ | . | $)*
## int: number+
##

require 'strscan'

class Lexer
  def lex_file(path)
    File.open(path, "r") do |file|
      while (line = file.gets)
        token = lex_line(line)
        yield token unless token.empty?
      end
    end
  end

  def lex_line(line)
    s = StringScanner.new line
    ret = []
    while !s.eos? && !s.scan(/\/\//) && !s.scan(/\n/)
      next if s.scan(/\s+/)
      if s.scan(/@/)
        ret << TokenAt.new
        next
      end
      if s.scan(/;/)
        ret << TokenSemiColon.new
        next
      end
      if s.scan(/\(/)
        ret << TokenLeftParen.new
        next
      end
      if s.scan(/\)/)
        ret << TokenRightParen.new
        next
      end
      if s.scan(/=/)
        ret << TokenAssign.new
        next
      end
      if s.scan(/-/)
        ret << TokenMinus.new
        next
      end
      if s.scan(/\+/)
        ret << TokenAdd.new
        next
      end
      if s.scan(/!/)
        ret << TokenNot.new
        next
      end
      if s.scan(/&/)
        ret << TokenAnd.new
        next
      end
      if s.scan(/\|/)
        ret << TokenOr.new
        next
      end
      x = s.scan(/\d+/)
      if x != nil
        ret << TokenNumber.new(x.to_i)
        next
      end

      y = s.scan(/[[:alpha:]]+(\w|\.|$)*/)
      if y != nil
        ret << TokenLabel.new(y)
        next
      end

      raise "unable to lex #{line}"
    end
    ret
  end
end

class Token
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

class TokenLabel < Token
  attr_reader :label
  
  def initialize(label)
    @label = label
  end
end

class TokenNumber < Token
  attr_reader :value

  def initialize(value)
    @value = value
  end
end
