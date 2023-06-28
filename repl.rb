require_relative "parser.rb"

i = 0
while true
  line = []
  print "nuni > "
  line << gets
  Parser.new(line).parse()
  i += 1
end
