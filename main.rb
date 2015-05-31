require './lexer.rb'
require './parser.rb'
require './translator.rb'

lexer = Lexer.new
parser = Parser.new
instructions =
  lexer.lex_file('../add/Add.asm').map {|tokens| parser.parse(tokens)}
translator = Translator.new

translator.translate(instructions).each do |line|
  puts line
end

