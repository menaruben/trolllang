require_relative "parser.rb"

lines = []
i = 0

while true
  print "nuni > "
  lines << gets
  Parser.new(lines).parse()
  i += 1
end
