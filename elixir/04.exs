defmodule Day04 do
  defp read_input do
    File.read!(Path.expand("../inputs/input04.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> line
      |> String.split(",")
      |> Enum.map(fn part -> part
        |> String.split("-")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  # Returns true if first range fully contains second
  defp range_contains_other?([r1_lo, r1_hi], [r2_lo, r2_hi]) do
    r1_lo <= r2_lo && r1_hi >= r2_hi
  end

  @doc """
  Find the number of pairs in which one range fully contains the other
  """
  def part1 do
    read_input()
    |> Enum.filter(fn [r1,r2] ->
      range_contains_other?(r1,r2) || range_contains_other?(r2,r1)
    end)
    |> Enum.count
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find the number of pairs in which one range overlaps or fully contains the other
  """
  def part2 do
    read_input()
    |> Enum.reject(fn [[r1_lo, r1_hi], [r2_lo, r2_hi]] ->
      Range.disjoint?(r1_lo..r1_hi, r2_lo..r2_hi)
    end)
    |> Enum.count
    |> IO.inspect(label: "P2")
  end
end

# P1: 441
# P2: 861
