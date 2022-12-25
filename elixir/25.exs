defmodule Day25 do
  defp read_input do
    File.read!(Path.expand("../inputs/input25.txt"))
      |> String.split("\n")
  end

  defp snafu_digit_to_decimal("="), do: -2
  defp snafu_digit_to_decimal("-"), do: -1
  defp snafu_digit_to_decimal(s), do: String.to_integer(s)

  defp snafu_to_decimal(snafu) do
    snafu
    |> String.graphemes
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.map(fn {d, i} -> (5 ** i) * snafu_digit_to_decimal(d) end)
    |> Enum.sum
  end

  defp quinary_digit_to_snafu("4"), do: "2"
  defp quinary_digit_to_snafu("3"), do: "1"
  defp quinary_digit_to_snafu("2"), do: "0"
  defp quinary_digit_to_snafu("1"), do: "-"
  defp quinary_digit_to_snafu("0"), do: "="

  @doc """
  Work out the fuel number by adding all the inputs
  Input numbers and answer use a balanced quinary system (SNAFU):
    2 represents 2 times column
    1 represents 1 times column
    0 represents 0 times column
    - represents -1 times column
    = represents -2 times column
  """
  def part1 do
    read_input()
      |> Enum.map(&snafu_to_decimal/1)
      |> Enum.sum
      |> then(fn decimal -> decimal + elem(Integer.parse("22222222222222222222", 5), 0) end) # prepare for quinary space
      |> then(fn superdecimal -> superdecimal
        |> Integer.to_string(5) # now in quinary space
        |> String.graphemes
        |> Enum.map(&quinary_digit_to_snafu/1) # reverts from quinary to balanced quinary (SNAFU)
        |> Enum.join
      end)
      |> String.trim_leading("0")
      |> IO.inspect(label: "P1") # "2----0=--1122=0=0021"
  end
end
