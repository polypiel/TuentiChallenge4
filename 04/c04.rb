#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 4
#
# Angel Calvo
#######################################

require "set"

def is_transition(from, to)
  diff = 0
  for i in 0..(from.length - 1)
	 diff += 1 if from[i] != to[i]
  end
  diff == 1
end

def build_transitions(from_states, to_states)
  transitions = {}
  from_states.each do |f|
  	to_states.each do |t|
  	  if is_transition(f,t)
    		transitions[f] = Set.new unless transitions[f]
    		transitions[f] << t
  	  end
  	end
  end
  transitions
end

# is the current state a solution?
def is_solution(state)
  state == $final
end

# Has been the node visited (takes in account the depth)
def is_visited(state, depth)
  $visited.has_key?(state) and $visited[state] <= depth
end

# update the solution only if it's better than previous
def update_solution(path)
  $solution = path if not $solution or path.length < $solution.length
end

# Is it the current solution better than the actual branck?
def worse(depth)
  $solution and (depth >= $solution.length)
end

# Finds the solution
def find(current, path)
  if is_solution(current)
	 update_solution(path << current)
  end
  depth = path.length + 1
  $visited[current] = depth
  unless worse(depth)  # prune if current path is worse than current solution
  	t = $transitions[current] || []
  	t.each do |child|
  	  find(child, path << current) unless is_visited(child, depth + 1) 
  	end
  end
end

# Main block
if __FILE__ == $0
  #tstart = Time.now
  
  initial = ARGF.readline.chomp
  $final = ARGF.readline.chomp
  states = []
  ARGF.each do |line|
	  states << line.chomp unless line.chomp.empty?
  end
  
  $transitions = build_transitions(Array.new(states) << initial, Array.new(states) << $final)
  
  $visited = {}
  $solution = nil
  
  find(initial, [])
  #time = Time.now - tstart
  
  puts $solution.join("->") if $solution
  #puts "#{time}s"
end
