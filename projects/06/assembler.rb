class Parser
  attr_reader :commands
  attr_accessor :index

  def initialize(file_name)
    @commands = []
    File.open(file_name) { |file| file.each do |line|
      line.chomp!
      line.sub!(/\/\/.*/m, '')
      line.strip!
      unless line.empty? 
        @commands << line 
      end
    end }
    @index = 0
  end
  
  def commands?
    !@commands[@index].nil?
  end

  def advance
    if commands?
      @command = @commands[@index]
      @index += 1
      @command
    end
  end

  def command_type
    case @command
    when /^@\w+/
      'A_COMMAND'
    when /([A-Z]+=.+|[A-Z0-9];[A-Z]+)/
      'C_COMMAND'
    else
      'L_COMMAND'
    end
  end

  def symbol
    if command_type != 'C_COMMAND'
      @command.gsub(/(^\(|\)$)/, '')
    end
  end

  def dest
    if command_type == 'C_COMMAND'
      Code.new.dest(@command)
    end
  end

  def comp
    if command_type == 'C_COMMAND'
      Code.new.comp(@command)
    end
  end

  def jump
    if command_type == 'C_COMMAND'
      Code.new.jump(@command)
    end
  end
end

class Code
  def dest(mnemonic)
    if mnemonic.match(/^[A-Z]+=/)
      mnemonic = mnemonic.to_s.sub(/=.+/, '') 
    end
    case mnemonic
    when 'M'
      '001'
    when 'D'
      '010'
    when 'MD'
      '011'
    when 'A'
      '100'
    when 'AM'
      '101'
    when 'AD'
      '110'
    else
      '000'
    end
  end

  def comp(mnemonic)
    if mnemonic.match(/=.+$/)
      mnemonic = mnemonic.to_s.sub(/^[A-Z]+=/, '')
    elsif mnemonic.match(/^[A-Z0-9]?;/)
      mnemonic = mnemonic.to_s.sub(/;[A-Z]+$/, '')
    end
    case mnemonic 
    when '0'
      '0101010'
    when 'D+A'
      '0000010'
    when 'D'
      '0001100'
    when 'D-1'
      '0001110'
    when 'D+1'
      '0011111'
    when '-1'
      '0111010'
    when 'A'
      '0110000'
    when 'A-1'
      '0110010'
    when 'A+1'
      '0110111'
    when '1'
      '0111111'
    when 'D&M'
      '1000000'
    when 'D+M'
      '1000010'
    when 'M-D'
      '1000111'
    when 'D-M'
      '1010011'
    when 'D|M'
      '1010101'
    when 'M'
      '1110000'
    when '!M'
      '1110001'
    when 'M-1'
      '1110010'
    when 'M+1'
      '1110111'
    else
      '0000000'
    end
  end

  def jump(mnemonic)
    right = mnemonic.match(/;[A-Z]+$/).to_s.sub(/;/, '')
    case right
    when 'JGT'
      '001'
    when 'JGE'
      '011'
    when 'JNE'
      '101'
    when 'JLE'
      '110'
    when 'JMP'
      '111'
    else
      '000'
    end
  end
end

class SymbolTable
  attr_reader :symbol_table
  def initialize
    @symbol_table = {} 
    @symbol_table[:R0]     = 0
    @symbol_table[:R1]     = 1
    @symbol_table[:R2]     = 2
    @symbol_table[:R5]     = 5
    @symbol_table[:R13]    = 13
    @symbol_table[:R14]    = 14
    @symbol_table[:R15]    = 15
    @symbol_table[:LCL]    = 1
    @symbol_table[:ARG]    = 2
    @symbol_table[:THIS]   = 3
    @symbol_table[:THAT]   = 4
    @symbol_table[:SCREEN] = 16384
  end

  def add_entry(symbol, address)
    @symbol_table[symbol.to_sym] = address
  end

  def contains?(symbol)
    @symbol_table.key? symbol.to_sym
  end

  def address(symbol)
    @symbol_table[symbol.to_sym]
  end
end

parser = Parser.new(ARGV[0])
commands = parser.commands

array = []
symbol_table = SymbolTable.new
while parser.commands? do
  command = parser.advance
  case parser.command_type
  when 'L_COMMAND'
    symbol_command = parser.symbol
    symbol_table.add_entry(symbol_command, array.length)
  else
    array << command
  end
end

parser.index = 0
hacked_commands = []
address = 16
while parser.commands? do
  command = parser.advance
  case parser.command_type
  when 'A_COMMAND'
    command.sub!(/^@/, '')
    if command.match(/^[a-z]+/) && !symbol_table.contains?(command.to_sym)
      symbol_table.add_entry(command, address)
      address += 1
    end

    if symbol_table.contains?(command.to_sym) || command.match(/^([a-z]|[A-Z])/)
      command = symbol_table.address(command.to_sym)
    end

    command = command.to_i.to_s(2)
    command = format("%016d", command)
  when 'C_COMMAND'
    command = '111' + parser.comp + parser.dest + parser.jump
  else
    command = nil
  end
  next if command.nil?
  hacked_commands << command
end

hack_file = ARGV[0].sub(/\.asm/, '.hack')
hack_content = hacked_commands.join("\n")
File.write(hack_file, hack_content)

