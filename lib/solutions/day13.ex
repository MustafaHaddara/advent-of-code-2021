defmodule Day13 do
  @test_input [
    "6,10",
    "0,14",
    "9,10",
    "0,3",
    "10,4",
    "4,11",
    "6,0",
    "6,12",
    "4,1",
    "0,13",
    "10,12",
    "3,4",
    "3,0",
    "8,4",
    "1,10",
    "2,14",
    "8,10",
    "9,0",
    "",
    "fold along y=7",
    "fold along x=5",
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    {coords, folds } = parse(input)
    coords
    |> make_map()
    |> apply_folds(Enum.reverse(folds), false)
    |> map_size()
  end

  def solve(input, _part = "b") do
    {coords, folds } = parse(input)
    coords
    |> make_map()
    |> apply_folds(Enum.reverse(folds), true)
    |> fmt()
  end

  defp parse(input) do
    input
    |> Enum.filter(fn line -> line != "" end)
    |> Enum.reduce({[], []}, fn (line, {coords, folds}) ->
      if String.starts_with?(line, "fold") do
        {coords, [line | folds]}
      else
        {[line | coords], folds}
      end
    end)
  end

  defp make_map(input) do
    input
    |> Enum.map(fn row ->
      row |> String.split(",") |> Enum.map(fn v -> String.to_integer(v) end)
    end)
    |> Enum.reduce(%{}, fn [x, y], all -> Map.put(all, {x,y}, true) end)
  end

  defp apply_folds(map, [], _) do
    map
  end
  defp apply_folds(map, [fold | rest], all) do
    [_, instruction] = String.split(fold, "fold along ")
    [axis, fold_val] = String.split(instruction, "=")

    new_state = map
    |> fold(axis, String.to_integer(fold_val))
    |> Enum.reduce(%{}, fn (coord, all) -> Map.put(all, coord, true) end)

    if all do
      apply_folds(new_state, rest, all)
    else
      new_state
    end
  end

  defp fold(map, "x", amount) do
    Enum.map(map, fn
      {{x,y}, _} when x > amount -> {amount - (x-amount), y}
      {{x,y}, _} -> {x,y}
    end)

  end
  defp fold(map, "y", amount) do
    Enum.map(map, fn
      {{x,y}, _} when y > amount -> {x, amount - (y-amount)}
      {{x,y}, _} -> {x,y}
    end)
  end

  defp fmt(map) do
    {max_x, max_y} = Enum.reduce(map, {nil, nil}, fn {{x,y}, _}, {max_x, max_y} ->
      new_max_x = if is_nil(max_x) or x>max_x, do: x, else: max_x
      new_max_y = if is_nil(max_y) or y>max_y, do: y, else: max_y
      { new_max_x, new_max_y }
    end)
    0..max_y |> Enum.each(fn y ->
      0..max_x |> Enum.map(fn x ->
        Map.get(map, {x,y}, false)
      end)
      |> Enum.map(fn f -> if f, do: "█", else: " " end)
      |> Enum.join("")
      |> IO.puts()
    end)
  end
end
