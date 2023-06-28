class Parser
  def initialize(lines, to_translate=false, output_file="")
    @keywords = {
      "let" => -> { parse_let() },
      "fn" => -> { parse_func_declaration() },
      "if" => -> { parse_if_statement() },
    }
    
    @std_funcs = {
      "println" => "puts",
      "print" => "print"
    }

    @to_translate = to_translate

    @defined_funcs = []
    @lines = lines
    @output_file = output_file
    @output_lines = []
    @line_idx = 0
    # @func_decl_mode = false
  end
  
  def parse_let()
    key, value = @lines[@line_idx].split "="
    if key[-1] == " "
      key = key[0..-2]
    end

    if value[0] == " "
      value = value[1..-1]
    end

    var_name = key[4..-1]
    @output_lines << "#{var_name} = eval('#{value}')\n"
  end

  def parse_func_usage()
    func_str = @lines[@line_idx].delete(",").split(" ")
    function_name = func_str[0]
    args_str = @lines[@line_idx][function_name.length()..-1]

    if @std_funcs.has_key? function_name
      func_str_new = "#{@std_funcs[function_name]} #{args_str}\n"

    else @defined_funcs.include? function_name
      func_str_new = "#{function_name} #{args_str}\n"
    
    end
    @output_lines << func_str_new
  end

  def parse_func_declaration()
    func_decl_str = @lines[@line_idx].split "="
    func_name = func_decl_str[0].split(" ")[1]
    @defined_funcs << func_name

    args = func_decl_str[1].split("{")[0].delete(" ").split(",")
    args_str = args.join ", "

    script_block = @lines[@line_idx].split("{")[1].delete("}").split(";")[0..-2]
    func_lines = []
    script_block.each do |line|
      if line.start_with?(" ") && line.end_with?(" ")
        func_lines << line[1..-2]

      elsif line.start_with?(" ")
        func_lines << line[1..-1]

      elsif line.end_with?(" ")
        func_lines << line[0..-2]

      else
        func_lines << line
      end
    end
    func_lines.each do |line|
      option = line.split(" ")[0]

      if @keywords.has_key? option
        @keyords[option].call

      elsif @std_funcs.has_key?(option) || @defined_funcs.include?(option)
        parse_func_usage()
        
      else
        raise "ERROR on line #{@line_idx + 1}: '#option' not found"
    end
    
    func_lines_str = func_lines.join("; ")
    
    func_decl = "def #{func_name}(#{args_str}); #{func_lines_str}; end\n"
    @output_lines << func_decl
  end

  # def parse_if_statement()
  # end
  
  def parse()
    @lines.each do |line|
      option = line.split(" ")[0]

      if @keywords.has_key? option
        @keywords[option].call
    
      elsif @std_funcs.has_key?(option) || @defined_funcs.include?(option)
        parse_func_usage()

      else
        raise "ERROR on line #{@line_idx + 1}: '#{option}' not found"
      end
    
      @line_idx += 1
    end

    if @to_translate
      translate_to_ruby()
    else
      run_code()
    end
  end

  def translate_to_ruby()
    @output_lines.each do |line|
      @output_file.write line
    end
  end
  
  def run_code()
    ruby_code = @output_lines.join()
    eval(ruby_code)
  end
end
