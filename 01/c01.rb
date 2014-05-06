#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 1
#
# Angel Calvo
#######################################

require "set"
STUDENTS_DB = "students"
NONE = "NONE"

# Adds a student to the classification tree
def insert_node(tree, student)
  genderNode = tree[student["gender"]]
  if !genderNode
	genderNode = Hash.new
	tree[student["gender"]] = genderNode
  end
  
  yearNode = genderNode[student["year"]]
  if !yearNode
	yearNode = Hash.new
	genderNode[student["year"]] = yearNode
  end

  ageNode = yearNode[student["age"]]
  if !ageNode
	ageNode = Hash.new
	yearNode[student["age"]] = ageNode
  end

  studiesNode = ageNode[student["studies"]]
  if !studiesNode
	studiesNode = SortedSet.new
	ageNode[student["studies"]] = studiesNode
  end
  
  studiesNode << student["name"]
end

# Finds a anonymous student
def find_node(tree, filter)
  names = nil
  if tree[filter["gender"]] and tree[filter["gender"]][filter["year"]] and tree[filter["gender"]][filter["year"]][filter["age"]] and tree[filter["gender"]][filter["year"]][filter["age"]][filter["studies"]]
	names = tree[filter["gender"]][filter["year"]][filter["age"]][filter["studies"]].to_a
  end
  return names
end

# Reads the students DB and builds the classification tree
def build_db(db_file)
  root = Hash.new
  File.open(db_file, "r") do |f|
  	f.each_line do |line|
  	  parts = line.split(",")
  	  student = {"name" => parts[0], "gender" => parts[1], "age" => parts[2], "studies" => parts[3], "year" => parts[4]}
  	  insert_node(root, student)
  	end
  end
  root
end

# Main block
if __FILE__ == $0
  tree = build_db STUDENTS_DB
  
  cases = ARGF.readline.to_i
  cases.times do |i|
	parts = ARGF.readline.split(",")
	filter = {"gender" => parts[0], "age" => parts[1], "studies" => parts[2], "year" => parts[3]}
	names = find_node(tree, filter)
	if names
	  names = names.join(",")
	else
	  names = NONE
	end
	puts "Case ##{i+1}: #{names}"
  end
end
