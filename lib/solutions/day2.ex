defmodule Day2 do
  @test_input [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    commands =
      input
      |> Enum.map(fn x -> String.split(x, " ") end)
      |> Enum.map(fn [c, a] -> [c, String.to_integer(a)] end)

    [depth, pos] = follow_instructions(commands, 0, 0)
    depth * pos
  end

  def solve(input, _part = "b") do
    commands =
      input
      |> Enum.map(fn x -> String.split(x, " ") end)
      |> Enum.map(fn [c, a] -> [c, String.to_integer(a)] end)

    [depth, pos, _aim] = follow_instructions(commands, 0, 0, 0)
    depth * pos
  end

  # part 1
  defp follow_instructions([[command, amount] | rest], depth, pos) when command == "forward" do
    follow_instructions(rest, depth, pos + amount)
  end

  defp follow_instructions([[command, amount] | rest], depth, pos) when command == "up" do
    follow_instructions(rest, depth - amount, pos)
  end

  defp follow_instructions([[command, amount] | rest], depth, pos) when command == "down" do
    follow_instructions(rest, depth + amount, pos)
  end

  defp follow_instructions([], depth, pos) do
    [depth, pos]
  end

  # part 2
  defp follow_instructions([[command, amount] | rest], depth, pos, aim)
       when command == "forward" do
    follow_instructions(rest, depth + aim * amount, pos + amount, aim)
  end

  defp follow_instructions([[command, amount] | rest], depth, pos, aim) when command == "up" do
    follow_instructions(rest, depth, pos, aim - amount)
  end

  defp follow_instructions([[command, amount] | rest], depth, pos, aim) when command == "down" do
    follow_instructions(rest, depth, pos, aim + amount)
  end

  defp follow_instructions([], depth, pos, aim) do
    [depth, pos, aim]
  end
end
