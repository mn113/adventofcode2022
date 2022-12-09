#!/usr/bin/env crystal

INPUT = File.read("../inputs/input09.txt").each_line.to_a
  .map{ |line| line.split(' ') }
  .map{ |pair| {dir: pair[0], amount: pair[1].to_i} }

DIRS = {
  "R" => {x: 1, y: 0},
  "L" => {x: -1, y: 0},
  "U" => {x: 0, y: 1},
  "D" => {x: 0, y: -1}
}

struct Point
  property x, y

  def initialize(@x : Int32, @y : Int32)
  end

  def x=(val)
    @x = val
    self
  end

  def y=(val)
    @y = val
    self
  end
end

# Are 2 nodes adjacent (incl. diagonally)?
def adjacent?(p1, p2)
  xlo = p1.x - 1
  xhi = p1.x + 1
  ylo = p1.y - 1
  yhi = p1.y + 1
  (xlo..xhi).includes?(p2.x) && (ylo..yhi).includes?(p2.y)
end

# Move head node
def move_node(node, dir)
  node.x += DIRS[dir][:x]
  node.y += DIRS[dir][:y]
  node
end

# Move child node
# - if too close, it will not move
# - if aligned in x or y with parent, it will move by 1 towards parent
# - otherwise it will move by 1 diagonally towards parent
def follow_node(child, parent)
  return child if adjacent?(child, parent)

  if parent.x > child.x
    child.x += 1
  elsif parent.x < child.x
    child.x -= 1
  end
  if parent.y > child.y
    child.y += 1
  elsif parent.y < child.y
    child.y -= 1
  end

  child
end

# Find the number of grid cells the rope tail visited (nodes: 2)
def part1
  head = Point.new(0,0)
  foot = Point.new(0,0)
  tail_set = Set(Point).new

  tail_set.add(foot)
  INPUT.each do |pair|
    pair[:amount].times do
      head = move_node(head, pair[:dir])
      foot = follow_node(foot, head)
      tail_set.add(foot)
    end
  end
  tail_set.size
end
puts "P1: #{part1()}" # 6339

# Find the number of grid cells the rope tail visited (nodes: 10)
def part2
  head = Point.new(0,0)
  neck = Point.new(0,0)
  chest = Point.new(0,0)
  abs = Point.new(0,0)
  hips = Point.new(0,0)
  thigh = Point.new(0,0)
  knee = Point.new(0,0)
  shin = Point.new(0,0)
  ankle = Point.new(0,0)
  foot = Point.new(0,0)
  tail_set = Set(Point).new

  tail_set.add(foot)
  INPUT.each do |pair|
    pair[:amount].times do
      head = move_node(head, pair[:dir])
      neck = follow_node(neck, head)
      chest = follow_node(chest, neck)
      abs = follow_node(abs, chest)
      hips = follow_node(hips, abs)
      thigh = follow_node(thigh, hips)
      knee = follow_node(knee, thigh)
      shin = follow_node(shin, knee)
      ankle = follow_node(ankle, shin)
      foot = follow_node(foot, ankle)
      tail_set.add(foot)
    end
  end
  tail_set.size
end
puts "P2: #{part2()}" # 2541
