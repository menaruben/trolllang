require_relative "parser.rb"

while true
  lines = []
  print "nuni > "
  lines << gets
  Parser.new(lines).parse()
end
