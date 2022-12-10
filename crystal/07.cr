#!/usr/bin/env crystal

INPUT = File.read("../inputs/input07.txt").lines

current_path = "";
dir_sizes = {
  "root" => 0
}

# Applies 'cd ..' on a stringified path
def parent(path_str)
  if path_str.includes?("/")
    path_str.split("/")[0...-1].join("/")
  else
    ""
  end
end

# Applies 'cd subdir' on a stringified path
def child(path_str, subdir)
  path_str + "/" + subdir
end

# Build up a filesystem
INPUT.each do |line|
  if line === "$ cd /" # first line only
    current_path = "root"

  elsif line === "$ cd .."
    current_path = parent(current_path)

  elsif line.starts_with? "$ cd "
    subdir = line[5..]
    current_path = child(current_path, subdir)

  elsif line.starts_with? "dir "
    subdir = line[4..]
    dir_sizes[child(current_path, subdir)] = 0 # ok because never revisited

  elsif line.match(/^\d/)
    bytes = line.split[0]

    dir_sizes[current_path] += bytes.to_i

    # Also add bytes onto every parent dir
    tmp_path = parent(current_path)
    while tmp_path.size > 0
      dir_sizes[tmp_path] += bytes.to_i
      tmp_path = parent(tmp_path)
    end
  end
end

# Find sum of all dir sizes up to 100kB
part1 = dir_sizes.values.select{ |size| size <= 100000 }.sum
puts "P1: #{part1}" # 1642503

# Find smallest dir to delete to free up space
space = 70000000
space_needed = 30000000
space_used = dir_sizes["root"]
to_delete = space_needed - (space - space_used)
part2 = dir_sizes.values.select{ |size| size >= to_delete }.sort.first
puts "P2: #{part2}" # 6999588
