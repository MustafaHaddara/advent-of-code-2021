defmodule Day11 do
  @test_input [
    "5483143223",
    "2745854711",
    "5264556173",
    "6141336146",
    "6357385478",
    "4167524645",
    "2176841721",
    "6882881134",
    "4846848554",
    "5283751526"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {i, j, c} end)
    end)
    |> Enum.reduce(%{}, &map_reducer/2)
    |> count_flashes(100, 0)
  end

  def solve(input, _part = "b") do
    input
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      row
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {i, j, c} end)
    end)
    |> Enum.reduce(%{}, &map_reducer/2)
    |> find_simultaneous(1)
  end

  # part 2
  defp find_simultaneous(initial_state, day) do
    before_flashes =
      initial_state
      |> Enum.map(fn {{i, j}, c} -> {i, j, c + 1} end)
      |> Enum.reduce(%{}, &map_reducer/2)

    will_flash =
      before_flashes
      |> Enum.filter(fn {_coord, c} -> c > 9 end)
      |> Enum.map(fn {{i, j}, _c} -> {i, j} end)

    {next_state, has_flashed} = apply_flashes(will_flash, %{}, before_flashes)

    new_flashes =
      has_flashed
      |> Enum.filter(fn {_k, v} -> v end)
      |> length()

    reset =
      next_state
      |> Enum.map(fn
        {{i, j}, v} when v > 9 -> {i, j, 0}
        {{i, j}, v} -> {i, j, v}
      end)
      |> Enum.reduce(%{}, &map_reducer/2)

    case new_flashes do
      100 -> day
      _ -> find_simultaneous(reset, day + 1)
    end
  end

  # part 1
  defp count_flashes(_initial_state, days_left, flashes) when days_left == 0 do
    flashes
  end

  defp count_flashes(initial_state, days_left, flashes) do
    before_flashes =
      initial_state
      |> Enum.map(fn {{i, j}, c} -> {i, j, c + 1} end)
      |> Enum.reduce(%{}, &map_reducer/2)

    will_flash =
      before_flashes
      |> Enum.filter(fn {_coord, c} -> c > 9 end)
      |> Enum.map(fn {{i, j}, _c} -> {i, j} end)

    {next_state, has_flashed} = apply_flashes(will_flash, %{}, before_flashes)

    new_flashes =
      has_flashed
      |> Enum.filter(fn {_k, v} -> v end)
      |> length()

    reset =
      next_state
      |> Enum.map(fn
        {{i, j}, v} when v > 9 -> {i, j, 0}
        {{i, j}, v} -> {i, j, v}
      end)
      |> Enum.reduce(%{}, &map_reducer/2)

    # |> fmt()

    count_flashes(reset, days_left - 1, flashes + new_flashes)
  end

  defp apply_flashes([], has_flashed, next_state) do
    {next_state, has_flashed}
  end

  defp apply_flashes([coord_to_flash | next_to_flash], has_flashed, next_state) do
    if Map.get(next_state, coord_to_flash) <= 9 do
      apply_flashes(next_to_flash, has_flashed, next_state)
    else
      if Map.get(has_flashed, coord_to_flash) do
        apply_flashes(next_to_flash, has_flashed, next_state)
      else
        sq = square_coords(coord_to_flash)

        # bump everyone around us
        intermediate =
          Enum.reduce(sq, next_state, fn coord, all ->
            Map.update!(all, coord, fn c -> c + 1 end)
          end)

        # add those cells to the list of upcoming flashes
        next = next_to_flash ++ sq
        flashed = Map.put(has_flashed, coord_to_flash, true)
        apply_flashes(next, flashed, intermediate)
      end
    end
  end

  defp square_coords({i, j}) do
    (i - 1)..(i + 1)
    |> Enum.flat_map(fn new_i ->
      (j - 1)..(j + 1)
      |> Enum.map(fn new_j ->
        {new_i, new_j}
      end)
    end)
    |> Enum.filter(fn {i, j} ->
      i >= 0 and j >= 0 and i < 10 and j < 10
    end)
  end

  defp map_reducer({i, j, c}, all) do
    Map.put(all, {i, j}, c)
  end

  # debug
  defp fmt(state) do
    0..9
    |> Enum.each(fn col ->
      0..9
      |> Enum.map(fn row ->
        Integer.to_string(Map.get(state, {col, row}))
      end)
      |> Enum.join(" ")
      |> IO.inspect()
    end)

    state
  end
end
