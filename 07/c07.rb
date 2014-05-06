#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 7
#
# Angel Calvo
#######################################

require "set"

CALLS_FILE = "phone_call.log"

# Adss a contact to A's graph
def add_contact_A(a, b)
  toDoSet = Set.new
  
  toDoSet << b if $A_graph.include? a
  toDoSet << a if $A_graph.include? b
  
  while not toDoSet.empty?
		n = toDoSet.take(1)[0]
		toDoSet.delete n
		
		unless $A_graph.include?(n)
		  neighbours = $graph[n] || []
		  neighbours.each do |neighbour|
			toDoSet << neighbour unless $A_graph.include?(neighbour)
		  end
		  $A_graph << n
		end
  end
end

# Adds a link to the general graph
def add_contact(a, b)
  $graph[a] = Set.new unless $graph[a]
  $graph[a] << b
  
  $graph[b] = Set.new unless $graph[b]
  $graph[b] << a
end

# Main block
if __FILE__ == $0
  A = ARGF.readline.chomp.to_i
  B = ARGF.readline.chomp.to_i

  tstart = Time.now
  
  $graph = Hash.new
  $A_graph = Set.new [A]
  
  File.open(CALLS_FILE, "r") do |f|
		f.each_line do |line|
		  from, to = line.split(" ").map {|x| x.to_i}
		  add_contact(from, to)
		  
		  add_contact_A(from, to)

		  if $A_graph.include?(B)
				#puts "#{Time.now - tstart}s"
				puts "Connected at #{f.lineno - 1}"
				exit()
			end
		end
  end
  #puts "#{Time.now - tstart}s"
  puts "Not connected"
end
