defmodule Day21 do
  @test_input [
    "Player 1 starting position: 4",
    "Player 2 starting position: 8"
  ]

  # d1  d2  d3  total
  # 1   1   1   3
  #         2   4
  #         3   5
  #     2   1   4
  #         2   5
  #         3   6
  #     3   1   5
  #         2   6
  #         3   7
  # 2   1   1   4
  #         2   5
  #         3   6
  #     2   1   5
  #         2   6
  #         3   7
  #     3   1   6
  #         2   7
  #         3   8
  # 3   1   1   5
  #         2   6
  #         3   7
  #     2   1   6
  #         2   7
  #         3   8
  #     3   1   7
  #         2   8
  #         3   9
  @frequencies %{
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1
  }

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    players = parse_input(input)

    play(players, 1000, 1, 0)
  end

  def solve(input, _part = "b") do
    players = parse_input(input)

    find_winner(players, [], 21)
    |> Enum.group_by(fn {winner, _} -> winner end, fn {_, times} -> times end)
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> IO.inspect()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.max()
  end

  # part 2
  defp find_winner([], next_loop, target) do
    players = Enum.reverse(next_loop)
    find_winner(players, [], target)
  end

  defp find_winner([{player_id, pos, score} | rest], next_loop, target) do
    @frequencies
    |> Enum.map(fn {roll, times} ->
      new_pos = loop(pos + roll, 10)
      new_score = score + new_pos
      {{player_id, new_pos, new_score}, times}
    end)
    |> Enum.flat_map(fn {{player_id, new_pos, new_score}, times} ->
      if new_score >= target do
        # IO.inspect({player_id, new_pos, new_score})
        [{player_id, times}]
      else
        find_winner(rest, [{player_id, new_pos, new_score} | next_loop], target)
        |> Enum.map(fn {winner, t} -> {winner, times * t} end)
      end
    end)
  end

  # part 1
  defp play(players, target, dice, num_turns) do
    {min_score, max_score} =
      players
      |> Enum.map(fn {_, _, score} -> score end)
      |> Enum.min_max()

    if max_score >= target do
      min_score * num_turns * 3
    else
      {new_players, new_dice, new_num_turns} = turn(players, target, dice, num_turns)
      play(new_players, target, new_dice, new_num_turns)
    end
  end

  defp turn([], _target, dice, num_turns) do
    {[], dice, num_turns}
  end

  defp turn([{player_id, pos, score} | rest], target, dice, num_turns) do
    d1 = dice
    d2 = next_dice(d1)
    d3 = next_dice(d2)
    next_pos = loop(pos + d1 + d2 + d3, 10)
    next_score = score + next_pos

    new_player_state = {player_id, next_pos, next_score}

    if next_score >= target do
      {[new_player_state | rest], d3, num_turns + 1}
    else
      {new_rest_players, new_dice, new_turns} = turn(rest, target, next_dice(d3), num_turns + 1)
      {[new_player_state | new_rest_players], new_dice, new_turns}
    end
  end

  defp next_dice(dice_val) do
    loop(dice_val + 1, 100)
  end

  defp loop(num, limit) when num <= limit do
    num
  end

  defp loop(num, limit) do
    loop(num - limit, limit)
  end

  defp parse_input(rows) do
    Enum.map(rows, fn row -> parse_row(row) end)
  end

  defp parse_row(row) do
    [_, player_id, _, _, starting_pos] = String.split(row, " ")
    {player_id, String.to_integer(starting_pos), 0}
  end
end
