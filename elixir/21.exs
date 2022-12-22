defmodule Day21 do
  defp read_input do
    File.read!(Path.expand("../inputs/input21.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> line
      |> String.split(": ")
    end)
    |> Enum.reduce(
      %{},
      fn [key, val], acc ->
        Map.put(acc, key, val)
      end
    )
  end

  # Look up a named monkey's yell
  # Recursive until it resolves to a number
  defp get_monkey_yell(defs, key) do
    #IO.inspect(key, label: "K")
    yell = Map.get(defs, key)# |> IO.inspect(label: "Y")
    if String.match?(yell, ~r/^\d+$/) do
      String.to_integer(yell) # handle string number or pure number
    else
      captures = Regex.named_captures(
        ~r/^(?<m1>[a-z]+) (?<op>[*+\/-]) (?<m2>[a-z]+)$/,
        yell
      )
      m1_yell = get_monkey_yell(defs, captures["m1"])
      m2_yell = get_monkey_yell(defs, captures["m2"])

      case captures["op"] do
        "*" -> m1_yell * m2_yell
        "/" -> div(m1_yell, m2_yell)
        "+" -> m1_yell + m2_yell
        "-" -> m1_yell - m2_yell
      end
    end
  end

  @doc """
  Work out the number the monkey named 'root' will yell
  """
  def part1 do
    read_input()
      |> get_monkey_yell("root")
      |> IO.inspect(label: "P1") # 118565889858886
  end

  # Test a 'humn' candidate number to see what the 'root' monkey says
  defp do_monkey_test(defs, candidate) do
    defs = %{defs | "humn" => candidate}
    get_monkey_yell(defs, "root")
  end

  # Search for the 'humn' number satisfying the test, between two boundaries
  defp binary_search(defs, a, z, goal \\ 0) do
    m = a + div(z - a, 2)
    ra = do_monkey_test(defs, "#{a}")
    rm = do_monkey_test(defs, "#{m}")
    rz = do_monkey_test(defs, "#{z}")
    cond do
      ra == goal -> a
      rm == goal -> m
      rz == goal -> z
      rm < goal && goal < ra -> binary_search(defs, a, m)
      rz < goal && goal < rm -> binary_search(defs, m, z)
    end
  end

  @doc """
  Find the 'humn' number required, to make the root monkey match its 2 values
  """
  def part2 do
    defs = read_input()
      |> Map.update!("root", &(String.replace(&1, "+", "-")))

    binary_search(defs, 0, 5000_000_000_000)
      |> IO.inspect(label: "P2") # 3032671800353, although 1 or 2 higher also satisfies
  end
end
