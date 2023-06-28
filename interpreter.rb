require_relative "parser.rb"

# parse code
input_file_name = ARGV[0].dup
input_file = File.open(input_file_name, "r")
input_file_content = input_file.read()
input_file_lines = input_file_content.split("\n").delete_if {|line| line == ""}
input_lines = []

input_file_lines.each do |line|
  line = line.split("//")[0]
  input_lines << line.split("//")[0]
end

input_file.close()

# to_translate = false
# if (ARGV.length() > 1 && ARGV[1].dup == "translate")
#   to_translate = true
#   input_file_name.slice!("nuni")
#   output_file_name = input_file_name + "rb"
#   output_file = File.open(output_file_name, "w")
#   p = Parser.new(input_lines, true, output_file)
#   output_file.close()

# else
#   p = Parser.new(input_lines, false)
#   p.parse()
# end

p = Parser.new(input_lines)
p.parse()