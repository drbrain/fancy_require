require 'fancy_require/rubygems'

look_up = $LOAD_PATH.find { |item| Gem::LookUp === item }

require 'rake'

puts "look_up.activated: #{look_up.activated.keys}"
puts
puts "look_up.load_path:"
puts "\t#{look_up.load_path.join "\n\t"}"
puts
puts "$LOAD_PATH:"
puts "\t#{$LOAD_PATH.join "\n\t"}"


