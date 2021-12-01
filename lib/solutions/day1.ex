defmodule Day1 do
  @test_input [
    "199",
    "200",
    "208",
    "210",
    "200",
    "207",
    "240",
    "269",
    "260",
    "263"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    [first | rest] = input |> Enum.map(fn x -> String.to_integer(x) end)
    count_increase(first, rest, 0)
  end

  def solve(input, _part = "b") do
    [first | rest] =
      input
      |> Enum.map(fn x -> String.to_integer(x) end)
      |> window3
      |> Enum.map(fn x -> Enum.sum(x) end)

    count_increase(first, rest, 0)
  end

  # part 1
  defp count_increase(first, [head | tail], total) when first < head do
    count_increase(head, tail, total + 1)
  end

  defp count_increase(_first, [head | tail], total) do
    count_increase(head, tail, total)
  end

  defp count_increase(_first, [], total) do
    total
  end

  # part 2
  defp window3([first | [second | [third | tail]]]) do
    [[first, second, third] | window3([second | [third | tail]])]
  end

  defp window3([_first | [_second | []]]) do
    []
  end
end
