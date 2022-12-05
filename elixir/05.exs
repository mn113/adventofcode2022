defmodule Day05 do
  defp read_input do
    File.read!(Path.expand("../inputs/input05_instructions.txt"))
    |> String.split("\n")
    |> Enum.map(fn line ->
      Regex.scan(~r/move (\d+) from (\d) to (\d)/, line)
      |> List.first
      |> tl
      |> Enum.map(&String.to_integer/1)
    end)
  end

  # Input hand-copied from input05_crates.txt
  defp initial_stacks do
    %{
      1 => "NCRTMZP",
      2 => "DNTSBZ",
      3 => "MHQRFCTG",
      4 => "GRZ",
      5 => "ZNRH",
      6 => "FHSWPZLD",
      7 => "WDZRCGM",
      8 => "SJFLHWZQ",
      9 => "SQPWN"
    }
  end

  # Move multiple crates from stack to stack by single operations
  # Recursive
  # Return new stacks
  defp execute_instruction_1by1(stacks, 1, from, to) do
    execute_move(stacks, from, to)
  end
  defp execute_instruction_1by1(stacks, amount, from, to) when amount > 1 do
    stacks2 = execute_move(stacks, from, to)
    execute_instruction_1by1(stacks2, amount - 1, from, to)
  end

  # Move single crate from stack to stack
  # Return new stacks
  defp execute_move(stacks, from, to) do
    crate = String.last(stacks[from])
    # Update both values in the stacks map and return it
    Map.update!(
      Map.update!(
        stacks,
        to,
        &(&1 <> crate)
      ),
      from,
      &(String.slice(&1, 0..-2))
    )
  end

  # Move multiple crates from stack to stack in one shot
  # Return new stacks
  defp execute_instruction_grouped(stacks, amount, from, to) do
    crates = String.slice(stacks[from], -amount, amount)
    # Update both values in the stacks map and return it
    Map.update!(
      Map.update!(
        stacks,
        to,
        &(&1 <> crates)
      ),
      from,
      &(String.slice(&1, 0..-(amount + 1)))
    )
  end

  @doc """
  Find the top crate of each stack after running the instructions
  Crates move 1 by 1
  """
  def part1 do
    read_input()
      |> Enum.reduce(
        initial_stacks(),
        fn [amount, from, to], stacks -> execute_instruction_1by1(stacks, amount, from, to) end
      )
      |> Map.values
      |> Enum.map(&String.last/1)
      |> Enum.join("")
      |> IO.inspect(label: "P1")
  end

  @doc """
  Find the top crate of each stack after running the instructions
  Crates move together, a whole instruction at a time
  """
  def part2 do
    read_input()
      |> Enum.reduce(
        initial_stacks(),
        fn [amount, from, to], stacks -> execute_instruction_grouped(stacks, amount, from, to) end
      )
      |> Map.values
      |> Enum.map(&String.last/1)
      |> Enum.join("")
      |> IO.inspect(label: "P2")
  end
end

# P1: RTGWZTHLD
# P2: STHGRZZFR
