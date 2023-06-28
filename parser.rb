class Parser
  def initialize(lines, to_translate = false, output_file = "")
    @keywords = {
      "let" => method(:parse_let),
      "fn" => method(:parse_func_declaration),
      "if" => method(:parse_if_statement)
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
    func_name = func_decl_str[0].split(" ")[1]
    @defined_funcs << func_name

    args = func_decl_str[1].split("{")[0].delete(" ").split(",")
    args_str = args.join(", ")

    script_block = line.split("{")[1].delete("}").split(";")[0..-2]
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

    "def #{func_name}(#{args_str}); #{func_lines_str}; end\n"
  end

  def parse_if_statement(line)
    #! TODO: Implement logic for parsing if statements here
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
    eval(ruby_code)
  end
end
