class Parser
  attr_reader :commands
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
    when /^push/
      'C_PUSH'
    when /^pop/
      'C_POP'
    else
      'C_ARITHMETIC'
    end
  end

  def first_arg
    case command_type
    when 'C_PUSH', 'C_POP'
      @command.gsub(/(^\w+ | \d+$)/, '')
    end
  end

  def second_arg
    case command_type
    when 'C_PUSH', 'C_POP'
      @command.gsub(/(\D)/, '').to_i
    end
   end
end

class CodeWriter
  def initialize(_)
    @commands = []
    @eqjmp = 0
    @gtjmp = 0
    @ltjmp = 0
  end

  def arithmetic(command)
    @commands << '@0' 
    @commands << 'M=M-1' 
    @commands << 'A=M' 

    # Relation
    case command
    when 'add', 'sub', 'eq', 'gt', 'lt', 'and', 'or'
      @commands << 'D=M' 
      @commands << '@0' 
      @commands << 'M=M-1'
      @commands << 'A=M'
    end

    case command
    when 'add'
      @commands << 'M=D+M'
    when 'sub'
      @commands << 'M=M-D'
    when 'neg'
      @commands << 'M=-M'
    when 'eq'
      @commands << 'D=M-D'
      @commands << 'M=-1'
      @commands << "@EQJMP#{@eqjmp}"
      @commands << 'D;JEQ'

      @commands << '@0' 
      @commands << 'A=M' 
      @commands << 'M=0'

      @commands << "(EQJMP#{@eqjmp})"
      @eqjmp += 1
    when 'gt'
      @commands << 'D=M-D'
      @commands << 'M=-1'
      @commands << "@GTJMP#{@gtjmp}" 
      @commands << 'D;JGT'

      @commands << '@0'
      @commands << 'A=M'
      @commands << 'M=0'

      @commands << "(GTJMP#{@gtjmp})"
      @gtjmp += 1
    when 'lt'
      @commands << 'D=M-D'
      @commands << 'M=-1'
      @commands << "@LTJMP#{@ltjmp}"
      @commands << 'D;JLT'

      @commands << '@0'
      @commands << 'A=M'
      @commands << 'M=0'

      @commands << "(LTJMP#{@ltjmp})"
      @ltjmp += 1
    when 'and'
      @commands << 'M=D&M'
    when 'or'
      @commands << 'M=D|M'
    when 'not'
      @commands << 'M=!M'
    end

    # M[0] = M[0] + 1
    @commands << '@0'
    @commands << 'M=M+1'
  end

  def push_pop(command, segment, index)
    case command
    when 'C_PUSH'
      case segment
      when 'constant'
        @commands << "@#{index}"
        @commands << 'D=A'
      when 'local'
        @commands << '@1'
        @commands << 'A=M'
        @commands << 'D=M'
      when 'argument'
        @commands << '@2'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      when 'this'
        @commands << '@3'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      when 'that'
        @commands << '@4'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      when 'pointer'
        @commands << '@3'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      when 'temp'
        @commands << '@5'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      when 'static'
        @commands << '@16'
        index.times do
          @commands << 'A=A+1'
        end
        @commands << 'D=M'
      end

      @commands << '@0'
      @commands << 'A=M'
      @commands << 'M=D'

      # M[0] = M[0] + 1
      @commands << '@0'
      @commands << 'M=M+1'
    when 'C_POP'
      @commands << '@0'
      @commands << 'M=M-1'
      @commands << 'A=M'
      @commands << 'D=M'

      case segment
      when 'local'
        @commands << '@1'
        @commands << 'A=M'
      when 'argument'
        @commands << '@2'
        @commands << 'A=M'
      when 'this'
        @commands << '@3'
        @commands << 'A=M'
      when 'that'
        @commands << '@4'
        @commands << 'A=M'
      when 'pointer'
        @commands << '@3'
      when 'temp'
        @commands << '@5'
      when 'static'
        #@commands << "@16.#{index}"
        @commands << '@16' 
      end

      index.times do
        @commands << 'A=A+1'
      end
      @commands << 'M=D'
    end
  end

  def close
    asm_file = ARGV[0].sub(/\.vm/, '.asm')
    content = @commands.join("\n")
    File.write(asm_file, content)
  end
end

parser = Parser.new(ARGV[0])
writer = CodeWriter.new(ARGV[0])

while parser.commands? do
  command = parser.advance
  case parser.command_type
  when 'C_PUSH', 'C_POP'
    writer.push_pop(parser.command_type, parser.first_arg, parser.second_arg)
  when 'C_ARITHMETIC'
    writer.arithmetic(command)
  end
end

writer.close
