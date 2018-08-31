require_relative 'jack_tokenizer'
require_relative 'compilation_engine'
require_relative 'util'

files = Dir["#{ARGV[0]}/*.jack"]
files.each do |file|
  jack_commands = []
  File.open(file) { |f| f.each do |line|
    line.slice! INLINE_COMMENT_REGEX
    next if line.match MULTILINE_COMMENT_REGEX
    line.chomp!
    line.strip!
    next if line.empty?
    line = line.scan(REGEX)
    line.each { |e| jack_commands << e[0] }
  end }

  tokenizer = JackTokenizer.new(jack_commands)
  tokens = []
  tokens << '<tokens>'
  while tokenizer.tokens? do
    command = tokenizer.advance
    case tokenizer.token_type
    when 'KEYWORD'
      tokens << '<keyword>' + tokenizer.key_word + '</keyword>'
    when 'SYMBOL'
      tokens << '<symbol>' + tokenizer.symbol + '</symbol>'
    when 'IDENTIFIER'
      tokens << '<identifier>' + tokenizer.identifier + '</identifier>'
    when 'STRING_CONST'
      tokens << '<stringConstant>' + tokenizer.string_val + '</stringConstant>'
    when 'INT_CONST'
      tokens << '<integerConstant>' + tokenizer.int_val + '</integerConstant>'
    end
  end
  tokens << '</tokens>'
  token_commands = tokens.join("\n")
  File.write("#{file.split('.')[0]}T.xml", token_commands)

  engine = CompilationEngine.new(jack_commands, tokens)
  engine.compile_class
  commands = engine.commands.join("\n")
  File.write("#{file.split('.')[0]}.xml", commands)
end

