require_relative 'util'

class JackTokenizer
  attr_reader :commands
  def initialize(commands)
    @commands = commands
    @index = 0
  end
  def tokens?
    !@commands[@index].nil?
  end
  def advance
    if tokens?
      @command = @commands[@index]
      @index += 1
      @command
    end
  end
  def token_type
    if @command.match KEYWORD
      'KEYWORD'
    elsif @command.match SYMBOL
      'SYMBOL'
    elsif @command.match STRING_CONST
      'STRING_CONST'
    elsif @command.match INT_CONST
      'INT_CONST'
    else
      'IDENTIFIER'
    end
  end
  def key_word
    @command
  end
  def symbol
    XML_CONVSERSIONS[:"#{@command}"] ? XML_CONVSERSIONS[:"#{@command}"] : @command
  end
  def identifier
    @command
  end
  def int_val
    @command
  end
  def string_val
    @command.gsub(/"/, '')
  end
end
