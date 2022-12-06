defmodule Day06 do
  defp read_input do
    File.read!(Path.expand("../inputs/input06.txt"))
  end

  # Find the string offset of the last of N unique consecutive characters
  defp find_unique_chain_end(chain, chain_length) do
    chain
      |> String.graphemes
      |> Enum.chunk_every(chain_length, 1, :discard)
      |> Enum.with_index
      |> Enum.find(fn {chain, _} -> MapSet.size(MapSet.new(chain)) == chain_length end)
      |> elem(1)
      |> then(&(&1 + chain_length))
  end

  @doc """
  Solve for chain of 4
  """
  def part1 do
    read_input()
      |> find_unique_chain_end(4)
      |> IO.inspect(label: "P1")
  end

  @doc """
  Solve for chain of 14
  """
  def part2 do
    read_input()
      |> find_unique_chain_end(14)
      |> IO.inspect(label: "P2")
  end
end

# P1: 1876
# P2: 2202
