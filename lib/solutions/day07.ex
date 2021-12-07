defmodule Day7 do
  @test_input [
    "16,1,2,0,4,2,7,1,2,14"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    positions =
      hd(input)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    min = Enum.min(positions)
    max = Enum.max(positions)

    calculate_fuels(positions, min, max, &cost_a/2)
  end

  def solve(input, _part = "b") do
    positions =
      hd(input)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    min = Enum.min(positions)
    max = Enum.max(positions)

    calculate_fuels(positions, min, max, &cost_b/2)
  end

  defp calculate_fuels(positions, min, max, cost_fn) do
    calculate_fuels(positions, min, max, nil, cost_fn)
  end

  defp calculate_fuels(_positions, min, max, smallest, _cost) when min >= max do
    smallest
  end

  defp calculate_fuels(positions, min, max, smallest, cost_fn) do
    f = calculate_fuel(positions, min, cost_fn)

    case is_nil(smallest) or f < smallest do
      true -> calculate_fuels(positions, min + 1, max, f, cost_fn)
      false -> calculate_fuels(positions, min + 1, max, smallest, cost_fn)
    end
  end

  defp calculate_fuel(positions, target, cost_fn) do
    positions |> Enum.map(fn e -> cost_fn.(e, target) end) |> Enum.sum()
  end

  defp cost_a(start, target) do
    abs(start - target)
  end

  defp cost_b(start, target) do
    steps = abs(start - target)
    round(steps * (steps + 1) / 2)
  end
end
