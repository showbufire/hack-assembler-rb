require './lexer.rb';

lexer = Lexer.new
lexer.lex_file 'Add.asm' do |result|
  p result
end
