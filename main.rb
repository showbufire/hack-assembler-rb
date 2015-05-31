require './lexer.rb'
require './parser.rb'
require './translator.rb'

lexer = Lexer.new
parser = Parser.new

raise "please provide a file name" if ARGV.length < 1
path = ARGV[0]
option = ARGV[1]

tokens_arr = lexer.lex_file(path)
if option == "-l"
  tokens_arr.map {|tokens| puts tokens}
  exit
end

instructions = tokens_arr.map {|tokens| parser.parse(tokens)}
if option == "-p"
  instructions.map {|ins| puts ins}
  exit
end

translator = Translator.new
translator.translate(instructions).each do |line|
  puts line
end
