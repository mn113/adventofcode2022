defmodule Day02 do

  @loses_to %{
    "Rock" => "Paper",
    "Paper" => "Scissors",
    "Scissors" => "Rock"
  }

  def loses_to, do: @loses_to
  def beats, do: Map.new(@loses_to, fn {key, val} -> {val, key} end)

  def score_symbol("Rock"), do: 1
  def score_symbol("Paper"), do: 2
  def score_symbol("Scissors"), do: 3

  def score_result(:loss), do: 0
  def score_result(:draw), do: 3
  def score_result(:win), do: 6

  defmodule Part1 do

    defp read_input do
      File.read!(Path.expand("../inputs/input02.txt"))
      |> String.split("\n")
      |> Enum.map(fn line -> line
        |> String.replace(["A", "X"], "Rock")
        |> String.replace(["B", "Y"], "Paper")
        |> String.replace(["C", "Z"], "Scissors")
        |> String.split(" ")
      end)
    end

    defp score_pair(["Rock", "Paper"]), do: Day02.score_result(:win) # win for us
    defp score_pair(["Paper", "Scissors"]), do: Day02.score_result(:win) # win for us
    defp score_pair(["Scissors", "Rock"]), do: Day02.score_result(:win) # win for us
    defp score_pair([s, s]), do: Day02.score_result(:draw) # draw
    defp score_pair([_s, _t]), do: Day02.score_result(:loss) # loss for us

    # We receive their symbol and our symbol, and have to compute the score based on our symbol's value and who won
    defp score_input_pair([them, us]) do
      Day02.score_symbol(us) + score_pair([them, us])
    end

    @doc """
    Find the total score of Rock-Paper-Scissors according to the scoring rules
    """
    def part1 do
      read_input()
      |> Enum.map(&score_input_pair/1)
      |> Enum.sum
      |> IO.inspect(label: "P1")
    end
  end

  defmodule Part2 do

    defp read_input do
      File.read!(Path.expand("../inputs/input02.txt"))
      |> String.split("\n")
      |> Enum.map(fn line -> line
        |> String.replace(["A"], "Rock")
        |> String.replace(["B"], "Paper")
        |> String.replace(["C"], "Scissors")
        |> String.replace(["X"], "loss")
        |> String.replace(["Y"], "draw")
        |> String.replace(["Z"], "win")
        |> String.split(" ")
      end)
    end

    defp derive_our_symbol(s, "draw"), do: s # all draws
    defp derive_our_symbol(s, "win"), do: Day02.loses_to[s] # all wins for us
    defp derive_our_symbol(s, "loss"), do: Day02.beats[s] # all losses for us

    # Now we receive their symbol and the desired round outcome, and have to derive our symbol and score it
    defp score_input_pair_part2([them, result]) do
      our = derive_our_symbol(them, result)
      Day02.score_symbol(our) + Day02.score_result(String.to_atom(result))
    end

    @doc """
    Find the total score of Rock-Paper-Scissors according to the new scoring rules
    """
    def part2 do
      read_input()
      |> Enum.map(&score_input_pair_part2/1)
      |> Enum.sum
      |> IO.inspect(label: "P2")
    end
  end
end

# P1: 15632
# P2: 14416
