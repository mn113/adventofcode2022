#!/usr/bin/env crystal

INPUT = File.read("../inputs/input06.txt")

# Find the string offset of the last of N unique consecutive characters
def find_unique_chain_end(chain, subchain_length)
  i = 0
  while i + subchain_length <= chain.size
    subchain = chain[i, subchain_length]
    break if subchain.chars.uniq.size == subchain_length
    i += 1
  end
  i + subchain_length
end

# Solve for chain of 4
def part1
  find_unique_chain_end(INPUT, 4)
end
puts "P1: #{part1()}" # 1876

# Solve for chain of 14
def part2
  find_unique_chain_end(INPUT, 14)
end
puts "P2: #{part2()}" # 2202
