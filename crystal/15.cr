#!/usr/bin/env crystal

record Point, x : Int64, y : Int64

def read_input
  sensors = {} of Point => Int64
  beacons = {} of Point => Bool
  min_x = max_x = 0

  File.read("../inputs/input15.txt").lines.map do |line|
    line.match(/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/)
    sensor = Point.new($1.to_i, $2.to_i)
    beacon = Point.new($3.to_i, $4.to_i)
    {sensor, beacon}
  end
  .each do |pair|
    sensor, beacon = pair
    md = manhattan_dist(sensor, beacon)
    sensors[sensor] = md
    beacons[beacon] = true
    min_x = sensor.x - md if sensor.x - md < min_x
    max_x = sensor.x + md if sensor.x + md > max_x
  end

  {sensors, beacons, min_x.as(Int64), max_x.as(Int64)}
end

def manhattan_dist(p1, p2)
  (p1.x - p2.x).abs + (p1.y - p2.y).abs
end

# Find the number of blocked cells in row 2000000
def part1 : Int32
  sensors, beacons, min_x, max_x = read_input()

  target_y = 2_000_000
  sensors_that_reach = sensors.select{ |k,v| (k.y - target_y).abs <= v }

  row = (min_x...max_x).to_a.map do |target_x|
    coord = Point.new(target_x, target_y)
    # check coord against each sensor coord & its maxdist
    # if cell is sensor, beacon, or reached by any sensor => cell blocked
    !beacons.has_key?(coord) &&
    !sensors.has_key?(coord) &&
    sensors_that_reach.any?{ |k,v| manhattan_dist(coord, k) <= v }
  end
  row.count(true)
end
puts "P1: #{part1()}" # 4424278

# check coord against each sensor coord & its maxdist
# if cell is not reached by any sensor => cell found!
def try_all_sensors(coord, sensors) : Bool
    !sensors.has_key?(coord) &&
    sensors.all?{ |k,v| manhattan_dist(coord, k) > v }
end

# check if coord outside of part 2 bounds
def out_of_bounds(coord) : Bool
  coord.x < 0 || coord.x > 4_000_000 || coord.y < 0 || coord.y > 4_000_000
end

# walk perimeter of each sensor's field until elusive beacon is found
def search_perimeters() : Point | Nil
  sensors, _ = read_input()

  seen = Set(Point).new
  sensors_seen = 0

  sensors.each do |k,v|
    top = Point.new(k.x, k.y - v - 1)
    bottom = Point.new(k.x, k.y + v + 1)
    left = Point.new(k.x - v - 1, k.y)
    right = Point.new(k.x + v + 1, k.y)

    coord = top
    while coord != left
      if !seen.includes?(coord) && !out_of_bounds(coord)
        return coord if try_all_sensors(coord, sensors)
        seen.add(coord)
      end
      coord = Point.new(coord.x - 1, coord.y + 1)
    end
    while coord != bottom
      if !seen.includes?(coord) && !out_of_bounds(coord)
        return coord if try_all_sensors(coord, sensors)
        seen.add(coord)
      end
      coord = Point.new(coord.x + 1, coord.y + 1)
    end
    while coord != right
      if !seen.includes?(coord) && !out_of_bounds(coord)
        return coord if try_all_sensors(coord, sensors)
        seen.add(coord)
      end
      coord = Point.new(coord.x + 1, coord.y - 1)
    end
    while coord != top
      if !seen.includes?(coord) && !out_of_bounds(coord)
        return coord if try_all_sensors(coord, sensors)
        seen.add(coord)
      end
      coord = Point.new(coord.x - 1, coord.y - 1)
    end
    sensors_seen += 1
    p "seen #{sensors_seen} sensor perimeters and #{seen.size} points"
  end
  Point.new(0,0) # avoids nil return type, won't be reached
end

# Part 2: find the location of the only undiscovered beacon in a field of 4million x 4million
def part2
  final_beacon = search_perimeters() # (2595657, 2753392)
  final_beacon.x * 4_000_000 + final_beacon.y
end
puts "P2: #{part2()}" # 10382630753392
