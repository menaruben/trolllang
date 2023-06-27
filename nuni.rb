# get nuni file content
input_file_name = ARGV[0].dup
input_file = File.open(input_file_name, "r")
input_file_content = input_file.read()
input_file_lines = input_file_content.split("\n")
input_lines = []

input_file_lines.each do |line|
  if line != ""
    line = line.split("//")[0]
    input_lines << line.split("//")[0]
  end
end

input_file.close()

# prepare ruby / output file
input_file_name.slice! "nuni"
output_file_name = input_file_name + "rb"
output_file = File.open(output_file_name, "w")

class Parser
  def initialize(lines, output_file)
    @keywords = {
      "let" => -> { parse_let() } ,
    }
    
    @std_funcs = {
      "println" => "puts",
      "print" => "print"
    }

    @defined_funcs = []
    
    @lines = lines
    @output_file = output_file
    @output_lines = []
    @line_idx = 0
    @func_decl_mode = false
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
    @output_lines << "#{var_name} = #{value}\n"
  end

  def parse_func_usage()
    func_str = @lines[@line_idx].split " "
    function_name = func_str[0]
    args = func_str[1..-1]
    args_str = args.join ", "

    func_str_new = "#{@std_funcs[function_name]} #{args_str}\n"
    @output_lines << func_str_new
  end

  def parse_func_declaration()
    func_decl_str = @lines[@line_idx].split "="
    func_name = func_decl_str[0][3..-1]
    func_name = func_name.delete " "
    @defined_funcs << func_name

    args = func_decl_str[1].split("{")[0].split(",").delete(" ")
    args_str = args.join ", "

    scriptblock = func_decl_str[1].split("{")[1].split(";")
    scriptblock_str = scriptblock.join("; ").delete "}"
    
    func_decl = "def #{func_name}(#{args_str}); #{scriptblock} end"

    @output_lines << func_decl
  end
  
  def parse()
    @lines.each do |line|
    option = line.split(" ")[0]

    if @keywords.has_key? option
      @keywords[option].call
    
    elsif @std_funcs.has_key? option
      name, args = parse_func_usage()

    else
      raise "ERROR on line #{@line_idx + 1}: '#{option}' not found"
    end
    
    @line_idx += 1
    end

    @output_lines.each do |line|
      @output_file.write line
    end
  end
end


# parse code
p = Parser.new(input_lines, output_file)
p.parse()

output_file.close()