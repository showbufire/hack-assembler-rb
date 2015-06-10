#!/usr/bin/env ruby

require './lexer.rb'
require './parser.rb'
require './translator.rb'

require 'slop'

opts = Slop.parse do |o|
  o.on '--help', '-h' do
    puts o
    exit
  end
  o.string '-f', '--file', 'path of .asm'
  o.bool '-l', '--lexer', 'only lexer'
  o.bool '-p', '--parser', 'only parser'
end


lexer = Lexer.new
path = opts[:file]
tokens_arr = lexer.lex_file(path)

if opts.lexer?
  tokens_arr.map {|tokens| puts tokens}
  exit
end

parser = Parser.new
instructions = tokens_arr.map {|tokens| parser.parse(tokens)}

if opts.parser?
  instructions.map {|ins| puts ins}
  exit
end

translator = Translator.new
translator.translate(instructions).each do |line|
  puts line
end
