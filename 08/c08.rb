#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 8
#
# Angel Calvo
#######################################

require "set"

TABLE_SIZE = 8
SEP = ", "
NO_SOLUTION = -1


class State
	attr_reader :table, :n_moves

	def initialize(table, n_moves = 0)
		@table = table
		@n_moves = n_moves
	end

	def eql?(other)
		@table == other.table
	end

	def hash
		@table.hash
	end

	# Returns all possible new configurations from a given state
	def moves
		[
			State.new([table[0], table[1], table[2], table[3], table[4], table[5], table[7], table[6]], n_moves+1),
			State.new([table[0], table[1], table[2], table[3], table[4], table[6], table[5], table[7]], n_moves+1),
			State.new([table[0], table[1], table[2], table[5], table[4], table[3], table[6], table[7]], n_moves+1),
			State.new([table[3], table[1], table[2], table[0], table[4], table[5], table[6], table[7]], n_moves+1),
			State.new([table[1], table[0], table[2], table[3], table[4], table[5], table[6], table[7]], n_moves+1),
			State.new([table[0], table[2], table[1], table[3], table[4], table[5], table[6], table[7]], n_moves+1),
			State.new([table[0], table[1], table[4], table[3], table[2], table[5], table[6], table[7]], n_moves+1),
			State.new([table[0], table[1], table[2], table[3], table[7], table[5], table[6], table[4]], n_moves+1),
		]
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
def solve(a, b)
	unvisited_queque = [State.new(a)]
	unvisited_set = Set.new unvisited_queque
	visited = Set.new

	while not unvisited_queque.empty?
		c = unvisited_queque[0]
		unvisited_queque.delete_at 0
		unvisited_set.delete(c)

		return c.n_moves if c.table == b
		neighbours = c.moves.select { |x| not visited.include? x and not unvisited_set.include? x}
		unvisited_queque.concat(neighbours)
		unvisited_set.merge(neighbours)

		visited << c
	end
	NO_SOLUTION
end

# Main block
if __FILE__ == $0
  n_tables = ARGF.readline.chomp.to_i
  initial_tables = Array.new(n_tables) {Array.new(TABLE_SIZE)}
  final_tables = Array.new(n_tables) {Array.new(TABLE_SIZE)}
  
  
  
  n_tables.times do |i|
  	$id = 1
  	names_map = Hash.new

		ARGF.readline
		aux = Array.new(TABLE_SIZE)
		aux[0], aux[1], aux[2] = ARGF.readline.chomp.split(SEP)
		aux[3], void, aux[4] = ARGF.readline.chomp.split(SEP)
		aux[5], aux[6], aux[7] = ARGF.readline.chomp.split(SEP)
		change_names(names_map, aux, initial_tables[i])

		ARGF.readline
		aux = Array.new(TABLE_SIZE)
		aux[0], aux[1], aux[2] = ARGF.readline.chomp.split(SEP)
		aux[3], void, aux[4] = ARGF.readline.chomp.split(SEP)
		aux[5], aux[6], aux[7] = ARGF.readline.chomp.split(SEP)
		change_names(names_map, aux, final_tables[i])
  end

 	# expected = [10, 10, 8, 7, 8, 7, 8, 4, 7, 10]
 	# Solves it
 	t1 = Time.now
 	#puts "Sol\tExpected"
  n_tables.times do |i|
  	move = solve(initial_tables[i], final_tables[i])
  	#puts "#{move}\t#{expected[i]}\t#{move==expected[i] ? 'OK' : 'WRONG'}" #\t#{move.path}"
  	puts move
  end
  t2 = Time.now - t1
  #puts "Time: #{t2}s"
  #puts "Estimated: #{(t2*80)/60}m"
end
