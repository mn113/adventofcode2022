#!/usr/bin/env crystal

# Read input
RANGE_PAIRS = File.read("../inputs/input04.txt").each_line.to_a.map do |line|
  line.split(",").map do |part|
    part.split("-").map do |d|
      d.to_i
    end
  end
end

# Returns true if first range fully contains second
def range_contains_other?(r1, r2)
  r1[0] <= r2[0] && r1[1] >= r2[1]
end

# Returns true if first range precedes and overlaps (or fully contains) second
def range_overlaps_other?(r1, r2)
  r1[0] <= r2[0] && r1[1] >= r2[0]
end

# Find the number of pairs in which one range fully contains the other
def part1
  RANGE_PAIRS
    .select do |pair|
      range_contains_other?(pair[0], pair[1]) || range_contains_other?(pair[1], pair[0])
    end
    .size
end
puts "P1: #{part1()}" # 441

# Find the number of pairs in which one range overlaps or fully contains the other
def part2
  RANGE_PAIRS
    .select do |pair|
      range_overlaps_other?(pair[0], pair[1]) || range_overlaps_other?(pair[1], pair[0])
    end
    .size
end
puts "P2: #{part2()}" # 861
