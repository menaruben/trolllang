class Parser
  def initialize(lines, to_translate = false, output_file = "")
    @keywords = {
      "let" => method(:parse_let),
      "fn" => method(:parse_func_declaration),
      "if" => method(:parse_if_statement),
      "for" => method(:parse_for_loop),
      "import" => method(:import),
      "#" => method(:eval_ruby_lines),
    }

    @std_funcs = {
      "println" => "puts",
      "print" => "print",
      "return" => "return",
    }

    @defined_funcs = []
    @to_translate = to_translate
    @lines = lines
    @output_file = output_file
    @line_idx = 0
  end

  def parse_let(line)
    key, value = line.split("=").map(&:strip)
    var_name = key[4..-1]
    "#{var_name} = eval('#{value}')\n"
  end

  def parse_func_usage(line)
    func_str = line.delete(",").split(" ")
    function_name = func_str[0]
    args_str = line[function_name.length..-1].strip

    if @std_funcs.has_key?(function_name)
      "#{@std_funcs[function_name]} #{args_str}\n"

    elsif @defined_funcs.include?(function_name)
      "#{function_name} #{args_str}\n"
    end
  end

  def parse_func_declaration(line)
    func_decl_str = line.split("=")
    # puts func_decl_str
    func_name = func_decl_str[0].split(" ")[1]
    # puts func_name
    @defined_funcs << func_name

    args = func_decl_str[1].split("{")[0].delete(" ").split(",")
    args_str = args.join(", ")

    script_block = line.split("{", 2)[1].delete("}").split(";;;")[0..-2]
    # puts script_block
    func_lines = script_block.map(&:strip)

    func_lines_ruby = []
    func_lines.each do |line|
      if line.start_with?(" ") && line.end_with?(" ")
        line = line[1..-2]
        func_lines_ruby << parse_line(line)

      elsif line.start_with?(" ")
        line = line[1..-1]
        func_lines_ruby << parse_line(line)

      elsif line.end_with?(" ")
        line = line[0..-2]
        func_lines_ruby << parse_line(line)

      else
        line = line
        func_lines_ruby << parse_line(line)
      end
    end
    func_lines_str = func_lines_ruby.join("; ")
    # puts func_lines_str
    
    "def #{func_name}(#{args_str}); #{func_lines_str}; end\n"
  end

  def parse_statement_block(statement_block)
    fields = statement_block.split " "
    statement = fields[0]
    if statement != "else"
      condition = fields[1]
      script_block = fields[3..-1]

    else
      script_block = fields[2..-1]    
    end
    
    statement_code = []

    if statement != "else"
      statement_code[0] = "#{statement} #{condition}\n"

    else
      statement_code[0] = "#{statement}\n"
    end
    
    current_line = []
    script_block.each_with_index do |sb, index|
      if index == 0
        sb = "\t" + sb
        current_line << sb
      else
        if sb.include? ";"
          sb = sb.gsub(";", "\n")
          current_line << sb
          statement_code << parse_line(current_line.join(" ")[1..-1])
          current_line = []
        else
          current_line << sb
        end
      end
    end

    statement_code.join(" ")
  end
  
  def parse_if_statement(line)
    statement_blocks = line.split ")"
    statement_strs = []
    
    statement_blocks.each do |statement|
      statement_strs <<  parse_statement_block(statement)
    end

    statement_strs << "end"
    statement_strs
  end

  def parse_script_block(line)
    script_block = line.split("{")[1].split(";")[0..-2]
    loopcode = []

    script_block.each do |sb|
      parsed_line = parse_line(sb) + "\n"
      loopcode << parsed_line
    end
    loopcode
  end
  
  def parse_scriptblock_lines(line)
    scriptblock = line.split("[")[1].split(";;")[0..-2]
    scriptblock_lines = []

    scriptblock.each do |sb|
      if sb.start_with?(" ") && sb.end_with?(" ")
        sb = sb[1..-2]
        scriptblock_lines << parse_line(sb)
        
      elsif sb.start_with?(" ")
        sb = sb[1..-1]
        scriptblock_lines << parse_line(sb)

      elsif sb.end_with?(" ")
        sb = sb[0..-2]
        scriptblock_lines << parse_line(sb)

      else
        scriptblock_lines << parse_line(sb)
      end
    end

    scriptblock_lines
  end
  
  def parse_for_loop(line)
    iter_str = line.split("[")[0] + "do"
    # puts iter_str
    scriptblock_lines = parse_scriptblock_lines(line)
    scriptblock_str = scriptblock_lines.join("; ")
    for_loop_str = "#{iter_str} #{scriptblock_str} end\n"
    for_loop_str
  end
  
  def import(file)
    file = file.split(" ")[1]
    # puts file
    parsed_lines = []
    File.readlines(file). each do |line|
      parsed_line = parse_line(line)
      parsed_lines << parsed_line + "\n"
    end
    parsed_lines.join("")
  end
  
  def eval_ruby_lines(line)
    ruby_line = line.split("#")[1]

    if line.start_with? " "
      ruby_line = ruby_line[1..-1] + "\n"
      ruby_line
    end
    ruby_line + "\n"
  end
  
  def parse_line(line)
    option = line.split(" ")[0]
    @line_idx += 1

    if @keywords.has_key?(option)
      @keywords[option].call(line)
    elsif @std_funcs.has_key?(option) || @defined_funcs&.include?(option)
      parse_func_usage(line)
    else
      raise "ERROR on line #{@line_idx}: '#{option}' not found"
    end
  end
  
  def parse
    @output_lines = @lines.map { |line| parse_line(line) }.compact

    if @to_translate
      translate_to_ruby()
    else
      run_code()
    end
  end

  def translate_to_ruby
    @output_lines.join("")
  end

  def run_code
    ruby_code = @output_lines.join("")
    # puts ruby_code
    eval(ruby_code)
  end
end
