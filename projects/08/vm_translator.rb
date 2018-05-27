class Parser
  attr_reader :commands, :sys_init
  def initialize(file_path)
    @commands = []
    files = Dir["#{file_path}/*.vm"]
    # Process Sys.init first
    if sys_file = files.grep(/Sys.vm$/)
      files.reject! { |file| file.match(/Sys.vm$/) }
      files.unshift sys_file
      files.flatten!
      @sys_init = true
    end
    files.each do |file|
      File.open(file) { |f| f.each do |line|
        line.chomp!
        line.sub!(/\/\/.*/m, '')
        line.strip!
        unless line.empty?
          @commands << line
        end
      end }
    end
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
    when /^label/
      'C_LABEL'
    when /^goto/
      'C_GOTO'
    when /^if-goto/
      'C_IF'
    when /^call/
      'C_CALL'
    when /^function/
      'C_FUNCTION'
    when 'return'
      'C_RETURN'
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
  def initialize(parser)
    @commands = []
    # initialize SP 256 if Sys.init?
    if parser.sys_init
      @commands << '@261'
      @commands << 'D=A'
      @commands << '@0'
      @commands << 'M=D'

      @commands << '@3000'
      @commands << 'D=A'
      @commands << '@3'
      @commands << 'M=D'

      @commands << '@4000'
      @commands << 'D=A'
      @commands << '@4'
      @commands << 'M=D'
    end
    @eqjmp = 0
    @gtjmp = 0
    @ltjmp = 0
    @function_num = 0
    @static_push_num = 0
    @static_pop_num = 0
  end

  def arithmetic(command)
    @commands << "// #{command}"
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
        index.times do
          @commands << 'A=A+1'
        end
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
        # @commands << "@16.#{index}"
        @commands << '@16'
        @static_push_num.times do
          @commands << 'A=A+1'
        end
        @static_push_num += 1
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
        index.times do
          @commands << 'A=A+1'
        end
      when 'argument'
        @commands << '@2'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
      when 'this'
        @commands << '@3'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
      when 'that'
        @commands << '@4'
        @commands << 'A=M'
        index.times do
          @commands << 'A=A+1'
        end
      when 'pointer'
        @commands << '@3'
        index.times do
          @commands << 'A=A+1'
        end
      when 'temp'
        @commands << '@5'
        index.times do
          @commands << 'A=A+1'
        end
      when 'static'
        # @commands << "@16.#{@static_pop_num}"
        @commands << '@16'
        @static_pop_num.times do
          @commands << 'A=A+1'
        end
        @static_pop_num += 1
      end

      @commands << 'M=D'
    end
  end

  def label(label)
    @commands << "(#{label})"
  end

  def goto(label)
    @commands << "// goto #{label}"
    @commands << "@#{label}"
    @commands << '0;JMP'
  end

  # If 0 don't go
  def if_goto(label)
    @commands << "// if_goto #{label}"
    @commands << '@0'
    @commands << 'M=M-1'
    @commands << 'A=M'
    @commands << 'D=M'
    @commands << "@#{label}"
    # IF out != 0 jump
    @commands << 'D;JNE'
  end

  def call_function(name, args_num)
    @commands << "// call #{name} #{args_num}"
    # push return-address
    push_pop('C_PUSH', 'constant', "call-#{name}-#{@function_num}")
    # push LCL
    @commands << '@1'
    @commands << 'D=M'
    @commands << '@0'
    @commands << 'A=M'
    @commands << 'M=D'
    @commands << '@0'
    @commands << 'M=M+1'
    # push ARG
    @commands << '@2'
    @commands << 'D=M'
    @commands << '@0'
    @commands << 'A=M'
    @commands << 'M=D'
    @commands << '@0'
    @commands << 'M=M+1'
    # push THIS
    @commands << '@3'
    @commands << 'D=M'
    @commands << '@0'
    @commands << 'A=M'
    @commands << 'M=D'
    @commands << '@0'
    @commands << 'M=M+1'
    # push THAT
    @commands << '@4'
    @commands << 'D=M'
    @commands << '@0'
    @commands << 'A=M'
    @commands << 'M=D'
    @commands << '@0'
    @commands << 'M=M+1'
    # ARG = SP - n - 5
    @commands << '@0'
    @commands << 'D=M'
    (args_num + 5).times do
      @commands << 'D=D-1'
    end
    @commands << '@2'
    @commands << 'M=D'
    # LCL = SP
    @commands << '@0'
    @commands << 'D=M'
    @commands << '@1'
    @commands << 'M=D'
    # goto f
    @commands << "@#{name}"
    @commands << '0;JMP'
    # (return-address)
    @commands << "(call-#{name}-#{@function_num})"
    @function_num += 1
  end

  def function(name, locals_num)
    @commands << "// function #{name} #{locals_num}"
    @commands << "(#{name})"
    locals_num.times do
      push_pop('C_PUSH', 'constant', 0)
    end
  end

  def return_function
    # FRAME = LCL
    @commands << '@1'
    @commands << 'D=M'
    @commands << '@13'
    @commands << 'M=D'
    # RET = *(FRAME - 5)
    5.times do
      @commands << 'D=D-1'
    end
    @commands << 'A=D'
    @commands << 'D=M'
    @commands << '@14'
    @commands << 'M=D'
    # *ARG = pop()
    push_pop('C_POP', 'argument', 0)
    # SP = ARG + 1
    @commands << '@2'
    @commands << 'D=M+1'
    @commands << '@0'
    @commands << 'M=D'
    # THAT = *(FRAME - 1)
    @commands << '@13'
    @commands << 'A=M'
    @commands << 'A=A-1'
    @commands << 'D=M'
    @commands << '@4'
    @commands << 'M=D'
    # THIS = *(FRAME - 2)
    @commands << '@13'
    @commands << 'A=M'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'D=M'
    @commands << '@3'
    @commands << 'M=D'
    # ARG = *(FRAME - 3)
    @commands << '@13'
    @commands << 'A=M'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'D=M'
    @commands << '@2'
    @commands << 'M=D'
    # LCL = *(FRAME - 4)
    @commands << '@13'
    @commands << 'A=M'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'A=A-1'
    @commands << 'D=M'
    @commands << '@1'
    @commands << 'M=D'
    # goto RET
    @commands << '@14'
    @commands << 'A=M'
    @commands << '0;JMP'
  end

  def close
    file_name = ARGV[0].split('/')[1]
    asm_file = "#{ARGV[0]}/#{file_name}.asm"
    content = @commands.join("\n")
    File.write(asm_file, content)
  end
end

parser = Parser.new(ARGV[0])
writer = CodeWriter.new(parser)

while parser.commands? do
  command = parser.advance
  case parser.command_type
  when 'C_PUSH', 'C_POP'
    writer.push_pop(parser.command_type, parser.first_arg, parser.second_arg)
  when 'C_ARITHMETIC'
    writer.arithmetic(command)
  when 'C_LABEL'
    label = command.split(' ')[1]
    writer.label(label)
  when 'C_GOTO'
    label = command.split(' ')[1]
    writer.goto(label)
  when 'C_IF'
    label = command.split(' ')[1]
    writer.if_goto(label)
  when 'C_CALL'
    name = command.split(' ')[1]
    args_num = command.split(' ')[2].to_i
    writer.call_function(name, args_num)
  when 'C_FUNCTION'
    name = command.split(' ')[1]
    locals_num = command.split(' ')[2].to_i
    writer.function(name, locals_num)
  when 'C_RETURN'
    writer.return_function
  end
end

writer.close
