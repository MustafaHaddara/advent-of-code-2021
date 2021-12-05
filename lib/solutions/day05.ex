defmodule Day5 do
  @test_input [
    "0,9 -> 5,9",
    "8,0 -> 0,8",
    "9,4 -> 3,4",
    "2,2 -> 2,1",
    "7,0 -> 7,4",
    "6,4 -> 2,0",
    "0,9 -> 2,9",
    "3,4 -> 1,4",
    "0,0 -> 8,8",
    "5,5 -> 8,2"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    input
    |> Enum.map(&parse_row/1)
    |> Enum.filter(fn [p1, p2] -> !is_diagonal(p1, p2) end)
    |> Enum.reduce(%{}, fn elem, acc -> fill_dict(elem, acc) end)
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> length()
  end

  def solve(input, _part = "b") do
    input
    |> Enum.map(&parse_row/1)
    |> Enum.reduce(%{}, fn elem, acc -> fill_dict(elem, acc) end)
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> length()
  end

  # part 1
  defp fill_dict([[x1, y1], [x2, y2]], dict) when x1 == x2 and y1 == y2 do
    Map.update(dict, [x1, y1], 1, fn e -> e + 1 end)
  end

  defp fill_dict([[x1, y1], [x2, y2]], dict) when x1 == x2 do
    inc = if y1 > y2, do: -1, else: 1
    new_dict = Map.update(dict, [x1, y1], 1, fn e -> e + 1 end)
    fill_dict([[x1, y1 + inc], [x2, y2]], new_dict)
  end

  defp fill_dict([[x1, y1], [x2, y2]], dict) when y1 == y2 do
    inc = if x1 > x2, do: -1, else: 1
    new_dict = Map.update(dict, [x1, y1], 1, fn e -> e + 1 end)
    fill_dict([[x1 + inc, y1], [x2, y2]], new_dict)
  end

  # part 2
  defp fill_dict([[x1, y1], [x2, y2]], dict) do
    xinc = if x1 > x2, do: -1, else: 1
    yinc = if y1 > y2, do: -1, else: 1
    new_dict = Map.update(dict, [x1, y1], 1, fn e -> e + 1 end)
    fill_dict([[x1 + xinc, y1 + yinc], [x2, y2]], new_dict)
  end

  # parsing
  defp parse_row(row) do
    [str_p1, str_p2] = String.split(row, " -> ")
    p1 = parse_point(str_p1)
    p2 = parse_point(str_p2)
    [p1, p2]
  end

  defp parse_point(chunk) do
    chunk
    |> String.split(",")
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  # filter
  defp is_diagonal([x1, y1], [x2, y2]) when x1 != x2 and y1 != y2 do
    true
  end

  defp is_diagonal(_, _) do
    false
  end
end
