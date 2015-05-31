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
      while (line = file.gets)
        tokens = lex_line(line)
        ret << tokens unless tokens.empty?
      end
    end
    ret
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
        ret << TokenSymbol.new(y)
        next
      end

      raise "unable to lex #{line}"
    end
    ret
  end
end
