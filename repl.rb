require_relative "parser.rb"

puts "Welcome to the trolllang REPL! I hope you're having an amazing day! :tf:"
lines = []
current_line = []

while true
  print ">>> "
  line = gets.chomp
  if line.start_with?("let") ||  line.start_with?("fn")
    lines << line
  end

  current_lines = lines + [line]
  

  Parser.new(current_lines, false, "").parse()
end
