defmodule Day18 do
  defp read_input do
    File.read!(Path.expand("../inputs/input18.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> line
      |> String.split(",")
      |> Enum.map(fn bits -> String.to_integer(bits) end)
    end)
  end

  # Count how many cubes (0-6) in the cubelist the candidate cube touches
  defp count_cube_touches(cube, cubelist) do
    cubelist
    |> Enum.map(fn cube2 -> if cube_touch?(cube, cube2), do: 1, else: 0 end)
    |> Enum.sum
  end

  # Do these 2 cubes touch?
  defp cube_touch?([x1,y1,z1], [x2,y2,z2]) do
    cond do
      x1 == x2 && y1 == y2 && z1 == z2 ->
        false # same cube!
      x1 == x2 && y1 == y2 && abs(z1 - z2) == 1 ->
        true
      x1 == x2 && z1 == z2 && abs(y1 - y2) == 1 ->
        true
      y1 == y2 && z1 == z2 && abs(x1 - x2) == 1 ->
        true
      true ->
        false
    end
  end

  # Find the exposed surface area of all listed cubes
  # (For each cube, it's 6 faces minus the number of touching neighbours)
  defp sum_exposed_faces(cubelist) do
    cubelist
      |> Enum.map(fn cube -> 6 - count_cube_touches(cube, cubelist) end)
      |> Enum.sum
  end

  @doc """
  Find the exposed surface area of all cubes
  """
  def part1 do
    read_input()
      |> sum_exposed_faces
      |> IO.inspect(label: "P1") # 3390
  end

  # Get the 6 3D neighbours of a cube (exclude out-of-bounds)
  defp neighbs([x,y,z]) do
    [
      [x-1,y,z], [x+1,y,z],
      [x,y-1,z], [x,y+1,z],
      [x,y,z-1],  [x,y,z+1]
    ]
    |> Enum.reject(fn cube -> Enum.any?(cube, fn coord -> coord < 0 or coord >= 20 end) end)
  end

  # Use BFS from origin to discover all outside air cubes
  defp discover_air_cubes(cubelist, origin \\ [0,0,0]) do
    do_discover_air_cubes(cubelist, [origin], [])
  end

  # Recursive BFS loop
  defp do_discover_air_cubes(cubelist, queue, seen) do
    [current | queue] = queue
    seen2 = [current|seen]
    nbs = neighbs(current)
      |> Enum.reject(fn nb -> nb in cubelist or nb in seen or nb in queue end)

    queue2 = Enum.concat(queue, nbs)

    if length(queue2) == 0 || length(seen) > 6000 do
      seen2
    else
      do_discover_air_cubes(cubelist, queue2, seen2)
    end
  end

  @doc """
  Find the exposed surface area of all cubes - minus interior pockets
  Assumes no lava cube floats inside a pocket!
  """
  def part2 do
    cubelist = read_input()

    range = 0..19
    all_cubes = (for x <- range, y <- range, z <- range, do: [x,y,z])
      |> MapSet.new

    air_cubes = discover_air_cubes(cubelist)
      |> MapSet.new

    pocket_cubes = all_cubes
      |> MapSet.difference(air_cubes)
      |> MapSet.difference(MapSet.new(cubelist))

    lava_cube_faces = sum_exposed_faces(cubelist)
    pocket_cube_faces = sum_exposed_faces(pocket_cubes)

    lava_cube_faces - pocket_cube_faces
      |> IO.inspect(label: "P2") #
  end
end
