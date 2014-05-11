#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 8
#
# Version 2: state as a 24 bit number (instead of as an array)
#
# Angel Calvo
#######################################

require "set"

INITIAL = 0x053977
MASKS = [0x00007, 0x000038, 0x0001C0, 0x000E00, 0x007000, 0x038000, 0x1C0000, 0xE00000].reverse
INV_MASKS = [0xFFFFF8, 0xFFFFC7, 0xFFFE3F, 0xFFF1FF, 0xFF8FFF, 0xFC7FFF, 0xE3FFFF, 0x1FFFFF].reverse

TABLE_SIZE = 8
SEP = ", "
NO_SOLUTION = -1


class State
	attr_reader :value, :n_moves
	@@moves = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7], [0, 7]]

	def initialize(value, n_moves = 0)
		@value = value
		@n_moves = n_moves
	end

	def eql?(other)
		@value == other.value
	end
	def hash
		@value.hash
	end

	# Returns all possible new configurations from a given state
	def moves
		m = []
		@@moves.each do |move|
			from, to = move

			p1 = @value & MASKS[from]
			p2 = @value & MASKS[to]

			shift = (to - from) * 3
			p1 = p1 >> shift
			p2 = p2 << shift

			num = (@value & INV_MASKS[from]) | p2
			num = (num & INV_MASKS[to]) | p1

			m << State.new(num, @n_moves + 1)
		end
		m
	end

	def self.build(table)
		num = 0
		table.each do |person|
			num = num << 3
			num = num | person
		end
		State.new num
	end

	def to_s
		@value
	end
end

# Maps people names to numbers
def change_names(map, names, target)
  names.each_with_index do |name, j|
	  if map[name]
			target[j] = map[name]
	  else
			target[j] = $id
			map[name] = $id
			$id += 1
	  end
  end
end

# Finds a solution with a BFT algorithm
def solve_bfs(initial, final)
	unvisited = [initial]
	visited = Set.new unvisited

	while not unvisited.empty?
		c = unvisited[0]
		unvisited.delete_at 0

		return c.n_moves if c.eql? final
		neighbours = c.moves.select { |x| not visited.include? x }
		unvisited.concat(neighbours)
		visited.merge neighbours
	end
	NO_SOLUTION
end

# Main block
if __FILE__ == $0
  n_tables = ARGF.readline.chomp.to_i
  initial_tables = Array.new(n_tables) {Array.new(TABLE_SIZE)}
  final_tables = Array.new(n_tables) {Array.new(TABLE_SIZE)}
  
  
  n_tables.times do |i|
  	$id = 0
  	names_map = Hash.new

		ARGF.readline
		aux = Array.new(TABLE_SIZE)
		aux[0], aux[1], aux[2] = ARGF.readline.chomp.split(SEP)
		aux[7], void, aux[3] = ARGF.readline.chomp.split(SEP)
		aux[6], aux[5], aux[4] = ARGF.readline.chomp.split(SEP)
		change_names(names_map, aux, initial_tables[i])

		ARGF.readline
		aux = Array.new(TABLE_SIZE)
		aux[0], aux[1], aux[2] = ARGF.readline.chomp.split(SEP)
		aux[7], void, aux[3] = ARGF.readline.chomp.split(SEP)
		aux[6], aux[5], aux[4] = ARGF.readline.chomp.split(SEP)
		change_names(names_map, aux, final_tables[i])
  end


 	# expected = [10, 10, 8, 7, 8, 7, 8, 4, 7, 10]
 	# # Solves it
 	# t1 = Time.now
 	#puts "Sol\tExpected"
  n_tables.times do |i|
   	move = solve_bfs(State.new(INITIAL), State.build(final_tables[i]))
   	#puts "#{move}\t#{expected[i]}\t#{move==expected[i] ? 'OK' : 'WRONG'}"
   	puts move
  end
  # t2 = Time.now - t1
  # puts "Time: #{t2}s"
  # puts "Estimated: #{(t2*80)/60}m"
end
