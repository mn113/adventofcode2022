defmodule Day10 do
  defp read_input do
    File.read!(Path.expand("../inputs/input10.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> line
      |> String.split()
      |> then(fn lineparts ->
        if length(lineparts) > 1 do
          [instr, num] = lineparts
          [instr, String.to_integer(num)]
        else
          lineparts
        end
      end)
    end)
  end

  defp initial_state do
    %{
      :x => 1,
      :addx_queue => [],
      :x_history => [1],
      :signal => 0,
      :signals_sum => 0,
      :cycles => 0
    }
  end

  # Run one program cycle
  defp do_exec_cycle(instr, state, finish \\ false) do
    state = Map.update!(state, :cycles, &(&1 + 1))

    # update signal strength and its sum on cycle 20, 60, 100...
    state = if rem(state.cycles + 20, 40) == 0 do
      strength = state.cycles * state.x
      state
        |> Map.update!(:signal, fn _ -> strength end)
        |> Map.update!(:signals_sum, &(&1 + strength))
    else
      state
    end

    state = cond do
      Enum.at(instr, 0) == "noop" ->
        state

      Enum.at(instr, 0) == "addx" && !finish ->
        # push to addx_queue
        Map.update!(state, :addx_queue, &(&1 ++ [Enum.at(instr, 1)]))

      Enum.at(instr, 0) == "addx" ->
        # shift from addx_queue & add to x
        if length(state.addx_queue) > 0 do
          [head|tail] = state.addx_queue
          new_x = state.x + head
          %{state | x: new_x, addx_queue: tail }
        else
          state
        end
    end

    # track x_history for part 2
    state = Map.update!(state, :x_history, &(&1 ++ [state.x]))

    if Enum.at(instr, 0) == "addx" && !finish,
      # begin second cycle with same instr
      do: do_exec_cycle(instr, state, true),
      else: state
  end

  defp run_all_instructions(input) do
    Enum.reduce(
      input,
      initial_state(),
      fn instr, state_acc -> do_exec_cycle(instr, state_acc) end
    )
  end

  @doc """
  Find the final signals_sum after all instructions
  """
  def part1 do
    read_input()
      |> run_all_instructions
      |> Map.get(:signals_sum)
      |> IO.inspect(label: "P1")
  end

  @doc """
  Draw the CRT output of x on a 40x6 display
  """
  def part2 do
    IO.inspect("P2:")
    read_input()
      |> run_all_instructions
      |> Map.get(:x_history)
      |> Enum.take(240)
      |> Enum.chunk_every(40)
      |> Enum.map(fn row -> row
        |> Enum.with_index
        |> Enum.map(fn {x,i} ->
          if x in (i-1)..(i+1), do: "#", else: "."
        end)
        |> Enum.join
      end)
      |> IO.inspect
  end
end

# P1: 31380
# P2: EZFCHJAB
