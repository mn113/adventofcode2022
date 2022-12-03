defmodule Day03 do
  defp read_input do
    File.read!(Path.expand("../inputs/input03.txt"))
    |> String.split("\n")
  end

  # Split each line into its front and back halves
  defp split_rucksack_to_bins(rucksack) do
    rucksack
    |> Enum.map(fn line -> line
      |> String.split_at(div(String.length(line), 2))
    end)
  end

  # Find the character common to 2 bins
  defp find_common_item(bin1, bin2) do
    str1 = String.graphemes(bin1)
    str2 = String.graphemes(bin2)
    Enum.find(str1, fn a -> a in str2 end)
  end

  # Find the character common to 3 bins
  defp find_common_item(bin1, bin2, bin3) do
    str1 = String.graphemes(bin1)
    str2 = String.graphemes(bin2)
    str3 = String.graphemes(bin3)
    Enum.find(str1, fn a -> a in str2 && a in str3 end)
  end

  # Scoring: a=1, z=26, A=27, Z=52
  defp score_item(char) do
    "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    |> String.graphemes
    |> Enum.find_index(fn x -> x == char end)
  end

  @doc """
  Find the sum of scores of the common item to the first and last half of each rucksack (line)
  """
  def part1 do
    read_input()
    |> split_rucksack_to_bins
    |> Enum.map(fn {bin1, bin2} -> find_common_item(bin1, bin2) end)
    |> Enum.map(&score_item/1)
    |> Enum.sum
    |> IO.inspect(label: "P1")
  end

  @doc """
  Find the sum of scores of the common item found in each chunk of 3 rucksacks (lines)
  """
  def part2 do
    read_input()
    |> Enum.chunk_every(3)
    |> Enum.map(fn [ruck1, ruck2, ruck3] -> find_common_item(ruck1, ruck2, ruck3) end)
    |> Enum.map(&score_item/1)
    |> Enum.sum
    |> IO.inspect(label: "P2")
  end
end

# P1: 7821
# P2: 2752
