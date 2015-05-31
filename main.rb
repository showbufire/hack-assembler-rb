require './lexer.rb'
require './parser.rb'

lexer = Lexer.new
parser = Parser.new
lexer.lex_file('../add/Add.asm').each do |tokens|
  p parser.parse(tokens)
end
