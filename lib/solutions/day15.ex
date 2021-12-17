defmodule Day15 do
  @test_input [
    "1163751742",
    "1381373672",
    "2136511328",
    "3694931569",
    "7463417111",
    "1319128137",
    "1359912421",
    "3125421639",
    "1293138521",
    "2311944581"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    int_input =
      input
      |> Enum.map(fn row ->
        row
        |> String.codepoints()
        |> Enum.map(fn c -> String.to_integer(c) end)
      end)

    map = make_map(int_input)

    s = length(input)

    starting = {0, 0}
    ending = {s - 1, s - 1}

    minimum_path(map, starting, ending, 0, %{starting => 0}, %{})
  end

  def solve(input, _part = "b") do
    multi = 5
    map = make_big_map(input, multi)

    s = length(input) * multi

    starting = {0, 0}
    ending = {s - 1, s - 1}

    minimum_path(map, starting, ending, 0, %{starting => 0}, [])
  end

  defp minimum_path(_map, starting, ending, cost, _distances, _unvisited)
       when starting == ending do
    cost
  end

  defp minimum_path(map, starting, ending, current_cost, distances, unvisited) do
    new_distances = Map.put(distances, starting, current_cost)
    # list of {cost, coord} tuples
    adjacent = Map.get(map, starting)

    adjacent_costs =
      adjacent
      |> Enum.filter(fn {_, coord} -> !Map.has_key?(new_distances, coord) end)
      |> Enum.map(fn {cost, coord} -> {cost + current_cost, coord} end)

    [{c, next_node} | new_unvisited] =
      adjacent_costs
      |> Enum.reduce(unvisited, fn node, acc ->
        update_unvisited(node, acc)
      end)
      |> Enum.filter(fn {_, coord} -> !Map.has_key?(new_distances, coord) end)

    minimum_path(map, next_node, ending, c, new_distances, new_unvisited)
  end

  defp update_unvisited(node, []) do
    [node]
  end

  defp update_unvisited(node, [head | rest]) do
    {node_cost, _} = node
    {head_cost, _} = head

    cond do
      node_cost > head_cost -> [head | update_unvisited(node, rest)]
      node_cost <= head_cost -> [node, head | rest]
    end
  end

  # part 1
  defp make_map(input) do
    size = length(input)

    input
    |> Enum.with_index()
    |> Enum.map(fn {row, index} -> parse_row(row, index, size) end)
    |> Enum.reduce(%{}, fn m1, acc ->
      Map.merge(acc, m1, fn _, v1, v2 -> v1 ++ v2 end)
    end)
  end

  defp parse_row(row, row_index, size) do
    row
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {weight, col_index}, acc ->
      parse_cell(weight, row_index, col_index, size, acc)
    end)
  end

  defp parse_cell(weight, row_index, col_index, size, existing_map) do
    cells = adjacent(row_index, col_index, size)
    val = {weight, {row_index, col_index}}

    Enum.reduce(cells, existing_map, fn cell, acc ->
      Map.update(acc, cell, [val], fn e -> [val | e] end)
    end)
  end

  def adjacent(row_index, col_index, size) do
    [
      {row_index - 1, col_index},
      {row_index + 1, col_index},
      {row_index, col_index - 1},
      {row_index, col_index + 1}
    ]
    |> Enum.filter(fn {x, y} -> x >= 0 and x < size and y >= 0 and y < size end)
  end

  # part 2
  defp make_big_map(input, times) do
    size = length(input) * times

    hor_dup =
      input
      |> Enum.map(fn row ->
        int_row =
          row
          |> String.codepoints()
          |> Enum.map(&String.to_integer/1)

        Enum.flat_map(0..(times - 1), fn i -> duplicate_row(int_row, i) end)
      end)

    rows =
      Enum.flat_map(0..(times - 1), fn i ->
        Enum.map(hor_dup, fn row -> duplicate_row(row, i) end)
      end)

    rows
    |> Enum.with_index()
    |> Enum.map(fn {row, index} -> parse_row(row, index, size) end)
    |> Enum.reduce(%{}, fn m1, acc ->
      Map.merge(acc, m1, fn _, v1, v2 -> v1 ++ v2 end)
    end)
  end

  defp duplicate_row(row, increment) do
    row
    |> Enum.map(fn c -> c + increment end)
    |> Enum.map(fn c ->
      cond do
        c > 9 -> c - 9
        true -> c
      end
    end)
  end
end
