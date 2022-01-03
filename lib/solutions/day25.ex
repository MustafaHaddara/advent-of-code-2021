defmodule Day25 do
  @test_input [
    "v...>>.vv>",
    ".vv>>.vv..",
    ">>.>v>...v",
    ">>v>>.>.v.",
    "v>v.vv.v..",
    ">.>>..v...",
    ".vv..>.>v.",
    "v.v..>>v.v",
    "....v..v.>"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    vsize = length(input)
    hsize = String.length(hd(input))
    state = parse_input(input)

    count_steps(state, {hsize, vsize}, 0)
  end

  # no part b for day 25!
  def solve(input, _part = "b") do
  end

  def count_steps(state, _, count) when is_nil(state) do
    count
  end

  def count_steps(state, sizes, current_count) do
    count_steps(evolve(state, sizes), sizes, current_count + 1)
  end

  def evolve(state, sizes) do
    {new_state, changed_right} = evolve_dir(state, sizes, ">")
    {new_state, changed_down} = evolve_dir(new_state, sizes, "v")

    if changed_right || changed_down do
      Enum.reduce(new_state, %{}, fn {coord, v}, all -> Map.put(all, coord, v) end)
    else
      nil
    end
  end

  def evolve_dir(state, sizes, dir) do
    {can_move, unchanged} =
      state
      |> Enum.split_with(fn {coord, v} -> v == dir and can_move?(state, coord, sizes) end)

    if can_move == [] do
      {state, false}
    else
      base_new_state = Map.new(unchanged)

      new_state =
        can_move
        |> Enum.map(fn {coord, v} -> {next_pos(coord, v, sizes), v} end)
        |> Enum.reduce(base_new_state, fn {coord, v}, all -> Map.put(all, coord, v) end)

      {new_state, true}
    end
  end

  def can_move?(state, coord, sizes) do
    val = Map.get(state, coord)
    next_coord = next_pos(coord, val, sizes)
    is_nil(Map.get(state, next_coord))
  end

  def next_pos(coord, val, {hsize, _}) when val == ">" do
    right(coord, hsize)
  end

  def next_pos(coord, val, {_, vsize}) when val == "v" do
    down(coord, vsize)
  end

  def right({x, y}, size) when x + 1 == size do
    {0, y}
  end

  def right({x, y}, _) do
    {x + 1, y}
  end

  def down({x, y}, size) when y + 1 == size do
    {x, 0}
  end

  def down({x, y}, _) do
    {x, y + 1}
  end

  defp parse_input(input) do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {c, _} -> c != "." end)
      |> Enum.map(fn {c, x} ->
        {x, y, c}
      end)
    end)
    |> Enum.reduce(%{}, fn {x, y, c}, all -> Map.put(all, {x, y}, c) end)
  end

  # debugging
  defp print_state(state, {hsize, vsize}) do
    0..(vsize - 1)
    |> Enum.each(fn y ->
      0..(hsize - 1)
      |> Enum.map(fn x -> Map.get(state, {x, y}, ".") end)
      |> Enum.join()
      |> IO.puts()
    end)
  end
end
