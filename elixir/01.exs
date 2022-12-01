defmodule Day01 do
  # Read input and transform to list of lists of numbers
  defp read_input do
    File.read!(Path.expand("../inputs/input01.txt"))
    |> String.split("\n\n")
    |> Enum.map(fn group -> group
        |> String.split("\n")
        |> Enum.map(fn line -> Integer.parse(line) end)
        |> Enum.map(fn {num, _} -> num end)
    end)
  end

  @doc """
  Find the group with the largest sum
  """
  def part1 do
    read_input()
    |> Enum.map(fn group -> Enum.sum(group) end)
    |> Enum.max
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find the groups with the top 3 largest sums
  """
  def part2 do
    read_input()
    |> Enum.map(fn group -> Enum.sum(group) end)
    |> Enum.sort
    |> Enum.reverse
    |> Enum.take(3)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 69693
# P2: 200945
