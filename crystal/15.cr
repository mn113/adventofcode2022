#!/usr/bin/env crystal

record Point, x : Int32, y : Int32

def read_input
  sensors = {} of Point => Int32
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

  {sensors, beacons, min_x, max_x}
end

def manhattan_dist(p1, p2)
  (p1.x - p2.x).abs + (p1.y - p2.y).abs
end

# Find the number of blocked cells in row 2000000
def part1
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

# Part 2: find the location of the only undiscovered beacon in a field of 40million x 40million
