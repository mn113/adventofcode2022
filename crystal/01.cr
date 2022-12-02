#!/usr/bin/env crystal

# Read input and transform to list of sums of number groups
ELVES = File.read("../inputs/input01.txt").split("\n\n").map do |group|
  group.split("\n").map{ |s| s.to_i }.sum
end

# Find the group with the largest sum
def part1
  ELVES.max
end
puts "P1: #{part1()}" # 69693

# Find the groups with the top 3 largest sums
def part2
  ELVES.sort.reverse[0,3].sum
end
puts "P2: #{part2()}" # 200945
