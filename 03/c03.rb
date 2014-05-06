#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 3
#
# Angel Calvo
#######################################

# Main block
if __FILE__ == $0
  cases = ARGF.readline.to_i
  cases.times do |i|
		x, y = ARGF.readline.split.map {|x| x.to_i}
		# sqrt(x² + y²)
		gamble = Math.sqrt(x*x + y*y).round(2)
		puts "#{gamble}"
  end
end
