#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 2
#
# Angel Calvo
#######################################

RIGHT = 0
DOWN = 1
LEFT = 2
UP = 3

# Represents a track segment
class Segment
	attr_reader :x, :y, :start, :value
  @value = nil

	def initialize(x, y, start=false)
		@x = x
		@y = y
		@start = start
  end

		# Assigns the output symbol
  def set_value(sprev, snext)
		if start
		  @value = '#'
		elsif sprev.y == snext.y
		  @value = '-'
		elsif sprev.x == snext.x
		  @value = '|'
		elsif ((sprev.x + 1 == @x and sprev.y == @y and @x == snext.x and @y + 1 == snext.y) or 
		       (sprev.x == @x and sprev.y - 1 == @y and @x - 1 == snext.x and @y == snext.y) or 
		       (sprev.x - 1 == @x and sprev.y == @y and @x == snext.x and @y - 1 == snext.y) or
		       (sprev.x == @x and sprev.y + 1 == @y and @x + 1 == snext.x and @y == snext.y))
		  @value = '\\'
		else
		  @value = '/'
		end
  end
end

# Main block
if __FILE__ == $0
  segments = []
  
  dir = RIGHT
  x = 0
  y = 0
  min_x = 0
  max_x = 0
  min_y = 0
  max_y = 0
  
  track = ARGF.readline.chomp.split("")
  # Reads the input and calc the size of the bounding box
  track.each do |c|
		s = Segment.new(x, y, c == '#')
		segments << s
		  
		if c == '/'
		  dir = ((dir == RIGHT or dir == LEFT) ? (dir - 1) : (dir + 1)) % 4
		elsif c == '\\'
		  dir =((dir == RIGHT or dir == LEFT) ? (dir + 1) : (dir - 1)) % 4
		end
		
		x += 1 if dir == RIGHT
		y += 1 if dir == DOWN
		x -= 1 if dir == LEFT
		y -= 1 if dir == UP
		
		# Updates mins and maxs
		min_x = x if x < min_x
		max_x = x if x > max_x
		min_y = y if y < min_y
		max_y = y if y > max_y
  end
  
  # Creates a matrix
  width = max_x - min_x + 1
  height = max_y - min_y + 1
  matrix = Array.new(height) {Array.new(width)}
  
  ssize = segments.length
  segments.each_with_index do |s, i|
		s.set_value(segments[(i-1) % ssize], segments[(i+1) % ssize])
		matrix[s.y - min_y][s.x - min_x] = s.value
  end
  
  # Prints solution
  matrix.each_with_index do |m, i|
		m.each_with_index do |v, j|
		  print "#{v || ' '}"
		end
		print "\n"
  end
end
