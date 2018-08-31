class CompilationEngine
  attr_reader :commands
  def initialize(jack_commands, tokens)
    @jack_commands = jack_commands
    @tokens = tokens
    @index = 0
    @commands = []
  end

  # 'class' className '{' classVarDec* subroutineDec* '}'
  def compile_class
    @commands << '<class>'
    @index += 1
    # 'class' className '{'
    next_token
    next_token
    next_token

    # classVarDec*
    while @tokens[@index].match(/(static|field)/)
      compile_class_var_dec
    end

    # subroutineDec*
    while !@tokens[@index].nil? && @tokens[@index].match(/(constructor|function|method)/)
      compile_subroutine
    end

    # '}'
    next_token
    @commands << '</class>'
  end

  # static,field
  # ('static' | 'field' ) type varName (',' varName) * ';'
  def compile_class_var_dec
    @commands << '<classVarDec>'
    # ('static' | 'field' ) type varName
    next_token
    next_token
    next_token

    # (',' varName) *
    while @tokens[@index].match(/(,|identifier)/)
      next_token
    end

    # ';'
    next_token
    @commands << '</classVarDec>'
  end

  # method,function,constructer
  def compile_subroutine
    @commands << '<subroutineDec>'
    4.times do
      next_token
    end
    compile_parameter_list
    next_token
    @commands << '<subroutineBody>'
    next_token
    while !@tokens[@index].nil? && @tokens[@index].match(/var/)
      compile_var_dec
    end
    compile_statements
    next_token
    @commands << '</subroutineBody>'
    @commands << '</subroutineDec>'
  end

  # ( (type varName) (',' type varName) *) ?
  def compile_parameter_list
    @commands << '<parameterList>'

    # (type varName)
    if !@tokens[@index].match(/\)/)
      next_token
      next_token
    end

    # (',' type varName) *
    while !@tokens[@index].nil? && !@tokens[@index].match(/\)/)
      next_token
      next_token
      next_token
    end

    @commands << '</parameterList>'
  end

  # 'var' type varName (',' varName) * ';'
  def compile_var_dec
    @commands << '<varDec>'
    # 'var' type varName
    next_token
    next_token
    next_token

    # (',' varName) *
    while @tokens[@index].match(/(,|identifier)/)
      next_token
    end

    # ';'
    next_token
    @commands << '</varDec>'
  end

  def compile_statements
    @commands << '<statements>'
    while !@tokens[@index].nil? && @tokens[@index].match(/(let|if|while|do|return)/)
      if @tokens[@index].match(/let/)
        compile_let
      elsif @tokens[@index].match(/if/)
        compile_if
      elsif @tokens[@index].match(/while/)
        compile_while
      elsif @tokens[@index].match(/do/)
        compile_do
      elsif @tokens[@index].match(/return/)
        compile_return
      end
    end
    @commands << '</statements>'
  end

  # 'do' subroutineCall ';'
  # subroutineCall: subroutineName '(' expressionList ')' | (className | varName) '.' subroutineName '(' expressionList ')'

  def compile_do
    @commands << '<doStatement>'
    # 'do' subroutineName | (className | varName)
    next_token
    next_token

    # '.' subroutineName
    if @tokens[@index].match(/\./)
      next_token
      next_token
    end

    # '(' expressionList ')' ';'
    next_token
    compile_expression_list
    next_token
    next_token
    @commands << '</doStatement>'
  end

  # 'let' varName ('[' expression ']')? '=' expression ';'
  def compile_let
    @commands << '<letStatement>'

    # 'let' varName
    next_token
    next_token

    # ('[' expression ']')?
    if @tokens[@index].match(/\[/)
      next_token
      compile_expression
      next_token
    end

    # '=' expression ';'
    next_token
    compile_expression
    next_token
    @commands << '</letStatement>'
  end

  # 'while' '(' expression ')' '{' statements '}'
  def compile_while
    @commands << '<whileStatement>'
    next_token
    next_token
    compile_expression
    next_token
    next_token
    compile_statements
    next_token
    @commands << '</whileStatement>'
  end

  # 'return' expression? ';'
  def compile_return
    @commands << '<returnStatement>'
    next_token
    if !@tokens[@index].match(/;/)
      compile_expression
    end
    next_token
    @commands << '</returnStatement>'
  end

  # 'if' '(' expression ')' '{' statements '}' ( 'else' '{' statements '}' )?
  def compile_if
    @commands << '<ifStatement>'
    next_token
    next_token
    compile_expression
    next_token
    next_token
    compile_statements
    next_token
    # ( 'else' '{' statements '}' )?
    if @tokens[@index].match(/else/)
      next_token
      next_token
      compile_statements
      next_token
    end
    @commands << '</ifStatement>'
  end

  # term (op term)*
  def compile_expression
    @commands << '<expression>'
    compile_term
    # op: '+'|'-'|'*'|'/'|'&'|'|'|'<'|'>'|'='
    while !@tokens[@index].nil? && @tokens[@index].match(/>(\+|-|\*|\/|&amp;|\||&lt;|&gt;|=)</)
      next_token
      compile_term
    end
    @commands << '</expression>'
  end

  # integerConstant | stringConstant | keywordConstant | varName |
  # varName '[' expression ']' | subroutineCall | '(' expression ')' | unaryOp term
  def compile_term
    @commands << '<term>'
    if !@tokens[@index].nil? && @tokens[@index].match(/(-|~)/)
      next_token
      compile_term
    elsif !@tokens[@index].nil? && @tokens[@index].match(/\(/)
      next_token
      compile_expression
      next_token
    else
      next_token
      if !@tokens[@index].nil? && @tokens[@index].match(/\[/)
        next_token
        compile_expression
        next_token
      elsif !@tokens[@index].nil? && @tokens[@index].match(/\./)
        next_token
        next_token
        next_token
        compile_expression_list
        next_token
      elsif !@tokens[@index].nil? && @tokens[@index].match(/\(/)
        next_token
        compile_expression_list
        next_token
      end
    end
    @commands << '</term>'
  end

  # (expression (',' expression)* )?
  def compile_expression_list
    @commands << '<expressionList>'
    if !@tokens[@index].match(/\)/)
      compile_expression
    end
    while !@tokens[@index].nil? && !@tokens[@index].match(/\)/)
      next_token
      compile_expression
    end
    @commands << '</expressionList>'
  end

  def next_token
    @commands << @tokens[@index]
    @index += 1
  end
end
