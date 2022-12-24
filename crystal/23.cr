#!/usr/bin/env crystal

record Point, x : Int64, y : Int64

# Store the elf positions as a set of points
def read_input
  elves = Set(Point).new
  File.read("../inputs/input23.txt").lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
      if c == '#'
        elves.add(Point.new(x,y))
      end
    end
  end
  elves
end

# The 8 neighbour points of a grid point
def neighbours(pt : Point)
  x = pt.x
  y = pt.y
  [
    Point.new(x-1, y-1), # NW
    Point.new(x, y-1),   # N
    Point.new(x+1, y-1), # NE
    Point.new(x-1, y),   # W
    Point.new(x+1, y),   # E
    Point.new(x-1, y+1), # SW
    Point.new(x, y+1),   # S
    Point.new(x+1, y+1)  # SE
  ]
end

# Elves consider where to move
def do_step1(elves, step)
  proposal = {} of Point => Point
  elves.each do |elf|
    nbs = neighbours(elf)
    bools = nbs.map{ |nb| elves.includes? nb }
    # p [elf, bools]
    if bools.reject{ |nb| nb }.size == 8
      # no need for elf to move
      #p "Next!"
      next
    else
      # first test rotates according to step
      case step % 4
      when 0 # N,S,W,E
        # consider NW,N,NE
        if !bools[0] && !bools[1] && !bools[2]
          #p "N ok"
          proposal[elf] = nbs[1]
        # consider SW,S,SE
        elsif !bools[5] && !bools[6] && !bools[7]
          #p "S ok"
          proposal[elf] = nbs[6]
        # consider NW,W,SW
        elsif !bools[0] && !bools[3] && !bools[5]
          #p "W ok"
          proposal[elf] = nbs[3]
        # consider NE,E,SE
        elsif !bools[2] && !bools[4] && !bools[7]
          #p "E ok"
          proposal[elf] = nbs[4]
        end
      when 1 # S,W,E,N
        # consider SW,S,SE
        if !bools[5] && !bools[6] && !bools[7]
          #p "S ok"
          proposal[elf] = nbs[6]
        # consider NW,W,SW
        elsif !bools[0] && !bools[3] && !bools[5]
          #p "W ok"
          proposal[elf] = nbs[3]
        # consider NE,E,SE
        elsif !bools[2] && !bools[4] && !bools[7]
          #p "E ok"
          proposal[elf] = nbs[4]
        # consider NW,N,NE
        elsif !bools[0] && !bools[1] && !bools[2]
          #p "N ok"
          proposal[elf] = nbs[1]
        end
      when 2 # W,E,N,S
        # consider NW,W,SW
        if !bools[0] && !bools[3] && !bools[5]
          #p "W ok"
          proposal[elf] = nbs[3]
        # consider NE,E,SE
        elsif !bools[2] && !bools[4] && !bools[7]
          #p "E ok"
          proposal[elf] = nbs[4]
        # consider NW,N,NE
        elsif !bools[0] && !bools[1] && !bools[2]
          #p "N ok"
          proposal[elf] = nbs[1]
        # consider SW,S,SE
        elsif !bools[5] && !bools[6] && !bools[7]
          #p "S ok"
          proposal[elf] = nbs[6]
        end
      when 3 # E,N,S,W
        # consider NE,E,SE
        if !bools[2] && !bools[4] && !bools[7]
          #p "E ok"
          proposal[elf] = nbs[4]
        # consider NW,N,NE
        elsif !bools[0] && !bools[1] && !bools[2]
          #p "N ok"
          proposal[elf] = nbs[1]
        # consider SW,S,SE
        elsif !bools[5] && !bools[6] && !bools[7]
          #p "S ok"
          proposal[elf] = nbs[6]
        # consider NW,W,SW
        elsif !bools[0] && !bools[3] && !bools[5]
          #p "W ok"
          proposal[elf] = nbs[3]
        end
      end
    end
  end
  proposal
end

# Spaces targeted by a single elf have that elf move to them
def do_step2(elves, proposal)
  moved = 0
  proposal.each do |elf, dest|
    if proposal.values.select{ |v| v == dest }.size == 1
      # elf can move
      elves.delete(elf)
      elves.add(dest)
      moved += 1
    end
  end
  {elves, moved}
end

# How many spaced in a 2d grid are unoccupied?
def count_spaces(elves)
  min_x, max_x = elves.to_a.map{ |elf| elf.x }.minmax
  min_y, max_y = elves.to_a.map{ |elf| elf.y }.minmax
  (1 + max_x - min_x) * (1 + max_y - min_y) - elves.size
end

# Print visual output
def print_grid(elves)
  min_x, max_x = elves.to_a.map{ |elf| elf.x }.minmax
  min_y, max_y = elves.to_a.map{ |elf| elf.y }.minmax
  (min_y..max_y).to_a.each do |y|
    row = ""
    (min_x..max_x).to_a.each do |x|
      row += elves.includes?(Point.new(x,y)) ? '#' : '.'
    end
    p row
  end
end

# Find the number of empty spaces after the elves move for 10 rounds
def part1
  elves = read_input()
  10.times do |s|
    proposal = do_step1(elves, s)
    elves, moved = do_step2(elves, proposal)
  end
  count_spaces(elves)
end
puts "P1: #{part1()}" # 4049

# Run the simulation until all elves have spread themselves out
def part2
  elves = read_input()
 1500.times do |s|
    proposal = do_step1(elves, s)
    elves, moved = do_step2(elves, proposal)
    return s + 1 if moved == 0
  end
  print_grid(elves)
end
puts "P2: #{part2()}" # 1020
