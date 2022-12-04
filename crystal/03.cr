#!/usr/bin/env crystal

# Read input
RUCKSACKS = File.read("../inputs/input03.txt").each_line.to_a

# Split each line into its front and back halves
def split_rucksack_to_bins(rucksack)
  binsize = rucksack.size.tdiv(2)
  a = rucksack.byte_slice(0, binsize)
  b = rucksack.reverse.byte_slice(0, binsize)
  {a, b}
end

# Find the character common to 2 bins
def find_common_item_of2(bin1, bin2)
  bin1.chars.find{ |a| bin2.includes?(a) }.to_s
end

# Find the character common to 3 bins
def find_common_item_of3(bin1, bin2, bin3)
  bin1.chars.find{ |a| bin2.includes?(a) && bin3.includes?(a) }.to_s
end

# Scoring: a=1, z=26, A=27, Z=52
def score_item(char)
  "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".index(char) || 0
end

# Find the sum of scores of the common item to the first and last half of each rucksack (line)
def part1
  RUCKSACKS
    .map{ |r| split_rucksack_to_bins(r) }
    .map{ |bins| find_common_item_of2(*bins) }
    .map{ |i| score_item(i) }
    .sum
end
puts "P1: #{part1()}" # 7821

# Find the sum of scores of the common item found in each chunk of 3 rucksacks (lines)
def part2
  RUCKSACKS
    .each_slice(3)
    .map{ |trio| {trio[0], trio[1], trio[2]} }
    .map{ |bins| find_common_item_of3(*bins) }
    .map{ |i| score_item(i) }
    .sum
end
puts "P2: #{part2()}" # 2752
