defmodule Day6 do
  @test_input [
    "3,4,3,1,2"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    hd(input)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> sim_state(80)
    |> length()
  end

  def solve(input, _part = "b") do
    hd(input)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn f, group ->
      Map.update(group, f, 1, fn existing -> existing + 1 end)
    end)
    |> grouped_sim_state(256)
    |> Map.values()
    |> Enum.sum()
  end

  # part 1: brute force
  defp sim_state(fish, days) when days == 0 do
    fish
  end

  defp sim_state(fish, days) do
    new_fish = Enum.flat_map(fish, fn f -> sim_single_fish(f) end)
    sim_state(new_fish, days - 1)
  end

  defp sim_single_fish(0) do
    [6, 8]
  end

  defp sim_single_fish(num) do
    [num - 1]
  end

  # part 2: not brute force
  defp grouped_sim_state(fish_group, days) when days == 0 do
    fish_group
  end

  defp grouped_sim_state(fish_group, days) do
    fish_group
    |> Enum.map(fn
      {0, num} -> %{6 => num, 8 => num}
      {n, num} -> %{(n - 1) => num}
    end)
    |> Enum.reduce(%{}, fn part, group ->
      Map.merge(part, group, fn _k, v1, v2 -> v2 + v1 end)
    end)
    |> grouped_sim_state(days - 1)
  end
end
