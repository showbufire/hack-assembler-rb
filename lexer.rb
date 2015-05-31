##
## symbols:
## @ ; ( ) = - + ! & |
## symbol: char+(char | number | _ | . | $)*
## int: number+
##

require 'strscan'
require './token.rb'

class Lexer
  def lex_file(path)
    ret = []
    File.open(path, "r") do |file|
      lineno = 1
      while (line = file.gets)
        tokens = lex_line(line, lineno)
        ret << tokens unless tokens.empty?
        lineno += 1
      end
    end
    ret
  end

  def lex_line(line, lineno)
    s = StringScanner.new line
    ret = []
    while !s.eos? && !s.scan(/\/\//) && !s.scan(/\n/)
      next if s.scan(/\s+/)
      if s.scan(/@/)
        ret << TokenAt.new(lineno)
        next
      end
      if s.scan(/;/)
        ret << TokenSemiColon.new(lineno)
        next
      end
      if s.scan(/\(/)
        ret << TokenLeftParen.new(lineno) 
        next
      end
      if s.scan(/\)/)
        ret << TokenRightParen.new(lineno)
        next
      end
      if s.scan(/=/)
        ret << TokenAssign.new(lineno)
        next
      end
      if s.scan(/-/)
        ret << TokenMinus.new(lineno)
        next
      end
      if s.scan(/\+/)
        ret << TokenAdd.new(lineno)
        next
      end
      if s.scan(/!/)
        ret << TokenNot.new(lineno)
        next
      end
      if s.scan(/&/)
        ret << TokenAnd.new(lineno)
        next
      end
      if s.scan(/\|/)
        ret << TokenOr.new(lineno)
        next
      end
      x = s.scan(/\d+/)
      if x != nil
        ret << TokenNumber.new(x.to_i, lineno)
        next
      end

      y = s.scan(/[[:alpha:]]+(\w|\.|\$)*/)
      if y != nil
        ret << TokenSymbol.new(y, lineno)
        next
      end

      raise "unable to lex #{line}"
    end
    ret
  end
end
