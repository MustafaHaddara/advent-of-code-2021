defmodule Day20 do
  @test_input [
    "..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#",
    "",
    "#..#.",
    "#....",
    "##..#",
    "..#..",
    "..###"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    [algo_str, _ | img_strs] = input
    algo = parse_algo(algo_str)
    img = parse_img(img_strs)

    enhanced = enhance_times(img, algo, 2, false)

    enhanced
    |> Enum.filter(fn {_k, v} -> v end)
    |> Enum.count()
  end

  def solve(input, _part = "b") do
    [algo_str, _ | img_strs] = input
    algo = parse_algo(algo_str)
    img = parse_img(img_strs)

    enhanced = enhance_times(img, algo, 50, false)

    enhanced
    |> Enum.filter(fn {_k, v} -> v end)
    |> Enum.count()
  end

  defp enhance_times(img, _algo, times, _background) when times == 0 do
    img
  end

  defp enhance_times(img, algo, times, background) do
    new_img = enhance(img, algo, background)
    enhance_times(new_img, algo, times - 1, !background)
  end

  # part 1
  defp enhance(img, algo, background) do
    {min_x, max_x} = img |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = img |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()

    buffer = 2

    (min_x - buffer)..(max_x + buffer)
    |> Enum.flat_map(fn x ->
      (min_y - buffer)..(max_y + buffer)
      |> Enum.map(fn y ->
        v = get_9_bit_val(x, y, img, background)
        {x, y, MapSet.member?(algo, v)}
      end)
    end)
    |> Enum.reduce(%{}, fn {x, y, v}, map -> Map.put(map, {x, y}, v) end)
  end

  defp get_9_bit_val(x, y, img, background) do
    (y - 1)..(y + 1)
    |> Enum.flat_map(fn newy ->
      (x - 1)..(x + 1)
      |> Enum.map(fn newx -> if Map.get(img, {newx, newy}, background), do: "1", else: "0" end)
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  # parsing
  defp parse_algo(algo_str) do
    algo_str
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.filter(fn {c, _i} -> c == "#" end)
    |> Enum.map(fn {_c, i} -> i end)
    |> Enum.reduce(MapSet.new(), fn i, set -> MapSet.put(set, i) end)
  end

  defp parse_img(img_strs) do
    img_strs
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {c, x, y} end)
    end)
    |> Enum.map(fn {c, x, y} -> {x, y, c == "#"} end)
    |> Enum.reduce(%{}, fn {x, y, v}, map -> Map.put(map, {x, y}, v) end)
  end

  # debugging
  defp inspect_img(img) do
    IO.puts("---")
    {min_x, max_x} = img |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = img |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()

    min_y..max_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        if Map.get(img, {x, y}), do: "#", else: " "
      end)
      |> Enum.join()
      |> IO.puts()
    end)

    IO.puts("---")

    img
  end
end
