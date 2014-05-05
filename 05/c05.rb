#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 5
#
# Angel Calvo
#######################################

SIZE = 8
ALIVE = 'X'
DEAD = '-'
MAX_ITERS = 100

# Una célula muerta con exactamente 3 células vecinas vivas "nace" (al turno siguiente estará viva).
# Una célula viva con 2 ó 3 células vecinas vivas sigue viva, en otro caso muere o permanece muerta (por "soledad" o "superpoblación").

# Represents a matrix/state as a 64bit number
def matrix_to_num(matrix)
  num = 0
  matrix.each do |row|
	row.each do |value|
	  num | 1 if value
	  num << 1
	end
  end
end

def print_matrix(matrix)
  matrix.each do |row|
	row.each do |value|
	  print value ? ALIVE : DEAD
	end
	print "\n"
  end
end

# Performs an iteration of Conway's life game
def conway(current)
  def conway_alive_neighbours(current, i, j)
	alive = 0
	alive += 1 if i - 1 >= 0 and j - 1 >= 0 and current[i - 1][j - 1]
	alive += 1 if j - 1 >= 0 and current[i][j - 1]
	alive += 1 if i + 1 < SIZE and j - 1 >= 0 and current[i + 1][j - 1]
	alive += 1 if i - 1 >= 0 and current[i - 1][j]
	alive += 1 if i + 1 < SIZE and current[i + 1][j]
	alive += 1 if i - 1 >= 0 and j + 1 < SIZE and current[i - 1][j + 1]
	alive += 1 if j + 1 < SIZE and current[i][j + 1]
	alive += 1 if i + 1 < SIZE and j + 1 < SIZE and current[i + 1][j + 1]
	alive
  end
  mnext = Array.new(SIZE) { Array.new(SIZE) }
  SIZE.times do |i|
	SIZE.times do |j|
	  alive = conway_alive_neighbours(current, i, j)
	  mnext[i][j] = if current[i][j]
		alive == 2 or alive == 3
	  else
		alive == 3
	  end
	end
  end
  mnext
end

# Main block
if __FILE__ == $0
  state = Array.new(SIZE) { Array.new(SIZE) }
  SIZE.times do |i|
  line = ARGF.readline.chomp
	SIZE.times do |j|
	  state[i][j] = line[j] == ALIVE
	end
  end

  # Loop
  patterns = { matrix_to_num(state) => 0}
  MAX_ITERS.times do |i|
	state = conway(state)
	#print_matrix(state)
	#puts ""
	pattern = matrix_to_num(state)
	if patterns.has_key?(pattern)
	  # Solution
	  iter = patterns[pattern]
	  puts "#{iter} #{i + 1 - iter}"
	  exit()
	end
	patterns[pattern] = i + 1
  end
end
