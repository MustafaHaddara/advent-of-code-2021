defmodule Day12 do
  @test_input [
    "start-A",
    "start-b",
    "A-c",
    "A-b",
    "b-d",
    "A-end",
    "b-end"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    input
    |> make_map()
    |> count_paths_1("start", %{}, ["start"])
  end

  def solve(input, _part = "b") do
    input
    |> make_map()
    |> count_paths_2("start", %{}, ["start"])
  end

  defp make_map(input) do
    input
    |> Enum.map(fn row -> String.split(row, "-") end)
    |> Enum.reduce(%{}, fn [s, e], all ->
      all
      |> Map.update(s, [e], fn existing -> [e | existing] end)
      |> Map.update(e, [s], fn existing -> [s | existing] end)
    end)
  end

  # part 1
  defp count_paths_1(_map, "end", _seen, _path) do
    # debug
    # IO.inspect(Enum.reverse(path))
    1
  end

  defp count_paths_1(map, pos, seen, path) do
    # we've seen ourselves
    s = update_seen(pos, seen)

    Map.get(map, pos, [])
    |> Enum.filter(fn next -> skip_small_1(next, s) end)
    |> Enum.map(fn next -> count_paths_1(map, next, s, [next | path]) end)
    |> Enum.sum()
  end

  defp skip_small_1("start", _) do
    false
  end

  defp skip_small_1("end", _) do
    true
  end

  defp skip_small_1(x, seen) do
    if is_small(x) do
      is_nil(Map.get(seen, x))
    else
      true
    end
  end

  # part 2
  defp count_paths_2(_map, "end", _seen, _path) do
    # debug:
    # IO.inspect(Enum.reverse(path))
    1
  end

  defp count_paths_2(map, pos, seen, path) do
    # we've seen ourselves
    s = update_seen(pos, seen)

    Map.get(map, pos, [])
    |> Enum.filter(fn next -> skip_small_2(next, s) end)
    |> Enum.map(fn next -> count_paths_2(map, next, s, [next | path]) end)
    |> Enum.sum()
  end

  defp skip_small_2("start", _) do
    false
  end

  defp skip_small_2("end", _) do
    true
  end

  defp skip_small_2(x, seen) do
    if is_small(x) do
      if is_nil(Map.get(seen, x)) do
        # never seen it, we can visit it
        true
      else
        # none of the other small ones have used our budget
        seen
        |> Enum.filter(fn {k, _} -> is_small(k) end)
        |> Enum.all?(fn {_, v} -> v < 2 end)
      end
    else
      true
    end
  end

  defp is_small(x) do
    c = x |> String.codepoints() |> hd()
    c >= "a" and c <= "z"
  end

  defp update_seen(pos, seen) do
    if is_small(pos) do
      Map.update(seen, pos, 1, fn e -> e + 1 end)
    else
      seen
    end
  end
end
