#!/usr/bin/env crystal

FOREST = File.read("../inputs/input08.txt").each_line.to_a.map{ |line| line.chars.map{ |c| c.to_i} }
FORESTXY = FOREST.transpose
DIM = FOREST.size

# Scan trees for visibility in 1 row
def build_vismap(row)
  tallest = -1
  # forward pass
  vismap_forward = row.map{ |t|
    if t > tallest
      tallest = t
      1
    else
      0
    end
  }
  # reverse pass
  tallest = -1
  vismap_reverse = row.reverse.map{ |t|
    if t > tallest
      tallest = t
      1
    else
      0
    end
  }.reverse
  vismap_forward.zip?(vismap_reverse).map{ |pair| pair == {0,0} ? 0 : 1 }
end

# Find the number of visible trees in the forest
def part1
  visible_trees = 0
  row_visibilities = FOREST.map{ |row| build_vismap(row) }
  col_visibilities = FORESTXY.map{ |row| build_vismap(row) }.transpose
  (0...DIM).each do |y|
    (0...DIM).each do |x|
      visible_trees += (row_visibilities[y][x] == 1 || col_visibilities[y][x] == 1) ? 1 : 0
    end
  end
  visible_trees
end
puts "P1: #{part1()}" # 1814

# Count along a list until sight is blocked by an equal-height tree
def measure_sightline(row_segment)
  h0 = row_segment[0]
  row_rest = row_segment[1..]
  dist = row_rest.index{ |h| h >= h0 } # found blocking tree
  dist.nil? ? row_rest.size : dist + 1
end

# Find and multiply the 4 sightlines of a tree at (x,y)
def product_of_sightlines(x,y)
  e = measure_sightline(FOREST[y][x..])
  return 0 if e == 0
  w = measure_sightline(FOREST[y][..x].reverse)
  return 0 if w == 0
  s = measure_sightline(FORESTXY[x][y..])
  return 0 if s == 0
  n = measure_sightline(FORESTXY[x][..y].reverse)

  e * w * s * n
end

# Find the highest 'scenic score' (tree with long views in 4 directions)
def part2
  scores = FOREST.clone # ensures children also cloned
  (0...DIM).each do |y|
    (0...DIM).each do |x|
      # discount edge trees
      if x == 0 || y == 0 || x == DIM - 1 || y == DIM - 1
        scores[y][x] = 0
      else
        scores[y][x] = product_of_sightlines(x,y)
      end
    end
  end
  scores.flatten.max
end
puts "P2: #{part2()}" # 330786
