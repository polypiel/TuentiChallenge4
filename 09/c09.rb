#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

#######################################
# Tuenti Challange 4
# Problem 9
#
# Angel Calvo
#######################################

DEST = "AwesomeVille"
ROAD = "normal"
DIRT = "dirt"

class Graph
	attr_reader :name, :nodes, :start_node, :end_node

	def initialize(name, num_nodes)
		@name = name
		@nodes = {}

		add_node @name
		add_node DEST
		num_nodes.times do |i|
			add_node(i.to_s)
		end
	end

	def add_node(id)
		 node = Node.new id
		 @nodes[id] = node

		 @start_node = node if id == @name
		 @end_node = node if id == DEST
	end

	def add_link(from, to, capacity)
		link = @nodes[from].add_link(@nodes[to], capacity)
		@nodes[to].add_link_from(link)
	end

	def max_flow(path)
		flows = []
		(path.length-1).times do |i|
			from = path[i]
			to = path[i + 1]
			link = from.get_link to
			if link
				flows << (link.capacity - link.flow)
			else
				link = to.get_link from
				flows << link.flow
			end
		end
		flows.min
	end

	def apply_flow(path, flow)
		(path.length-1).times do |i|
			from = path[i]
			to = path[i + 1]
			link = from.get_link to
			if link
				link.flow += flow
			else
				link = to.get_link from
				link.flow -= flow
			end
		end
	end

	def inspect
		puts name
		@nodes.each do |id, node|
			print id
			print " (start)" if @start_node == node
			print " (end)" if @end_node == node
			print "\n"
			node.links.each do |link|
				puts "\t--(#{link.flow}/#{link.capacity})--> #{link.to} "
			end
		end
	end
end

class Node
	attr_reader :id, :links, :all_links

	def initialize(id)
		@id = id
		@links = []
		@all_links = []
	end

	def add_link(to_node, capacity)
		link = Link.new(self, to_node, capacity)
		@links << link
		@all_links << link
		link
	end

	def add_link_from(link)
		@all_links << link
	end

	def get_link(to)
		@links.each do |link|
			return link if link.to == to
		end
		nil
	end

	def backward_links
		@all_links - @links
	end

	def forward_link?(link)
		nil if link.from != self and link.to != self
		link.from == self
	end

	def backward_link?(link)
		nil if link.from != self and link.to != self
		link.to == self
	end

	def augmenting?(link)
		(forward_link? link and not link.full?) or (backward_link? link and not link.empty?)
	end

	def get_augmenting_node(link)
		self if forward_link?(link)
		link.to
	end

	def to_s
		@id
	end
end

class Link
	attr_reader :from, :to, :capacity
	attr_accessor :flow

	def initialize(from, to, capacity)
		@from = from
		@to = to
		@capacity = capacity
		@flow = 0
	end

	def full?
		@flow == @capacity
	end

	def empty?
		@flow == 0
	end

	def to_s
		"#{@from} --(#{@flow}/#{@capacity})--> #{@to}"
	end
end


def print_path(path)
	if not path.empty?
		print path[0]
	end
	if path.length > 1
		(path.length - 1).times do |i|
			from = path[i]
			to = path[i + 1]
			link = from.get_link(to)
			print " --(#{link.flow}/#{link.capacity})--> #{to}"
		end
	end
	print "\n"
end

def path_included?(path, node, link)
	node = link.to if node.forward_link? link
	path.include? node
end

def find_augmenting_path(graph)
	queque = [[graph.start_node]]

	iters = 0
	while not queque.empty?
		path = queque[0]
		queque.delete_at 0
		c = path.last
		new_links = c.all_links.select { |l| c.augmenting?(l) and not path_included?(path, c, l)}
		new_links.each do |new_link|
			new_node = c.get_augmenting_node(new_link)
			new_path = path.dup << new_node
			return new_path if new_node == graph.end_node
			queque << new_path
		end
		iters += 1
	end
	nil
end

def ford_fulkerson(graph)
	until not (path = find_augmenting_path(graph))
		max_flow = graph.max_flow path
		graph.apply_flow path, max_flow
	end

	flow = 0
	graph.end_node.backward_links.each do |link|
		flow += link.flow
	end
	flow
end

# Main block
if __FILE__ == $0
	n_cases = ARGF.readline.chomp.to_i

	graphs = Array.new(n_cases)

	n_cases.times do |index|
		name = ARGF.readline.chomp

		road_vel, dirt_vel = ARGF.readline.chomp.split(" ").map {|x| x.to_i}
		vels = {ROAD => road_vel, DIRT => dirt_vel}
		n_intersections, n_roads = ARGF.readline.chomp.split(" ").map {|x| x.to_i}

		graph = Graph.new(name, n_intersections)

		n_roads.times do |j|
			from, to, type, lanes = ARGF.readline.chomp.split(" ")
			graph.add_link from, to, lanes.to_i*vels[type]
		end

		graphs[index] = graph
	end

	n_cases.times do |i|
		flow = ford_fulkerson(graphs[i]) * 200
		puts "#{graphs[i].name} #{flow}"
	end
end
