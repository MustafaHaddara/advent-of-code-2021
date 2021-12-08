defmodule Day8 do
  # @test_input [
  #   "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"
  # ]

  @test_input [
    "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe",
    "edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc",
    "fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg",
    "fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb",
    "aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea",
    "fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb",
    "dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe",
    "bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef",
    "egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb",
    "gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    input
    |> Enum.map(fn line -> String.split(line, " | ") end)
    |> Enum.map(fn [_signals, output] ->
      output
      |> String.split(" ")
      |> Enum.map(&String.length/1)
      |> Enum.filter(fn l -> l == 2 or l == 4 or l == 3 or l == 7 end)
      |> length()
    end)
    |> Enum.sum()
  end

  def solve(input, _part = "b") do
    input
    |> Enum.map(fn line -> String.split(line, " | ") end)
    |> Enum.map(&solve_row/1)
    |> Enum.sum()
  end

  def solve_row([signals, output]) do
    segments_a =
      signals
      |> String.split(" ")
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(&Enum.sort/1)
      |> find_nums(%{})
      |> IO.inspect()

    segments =
      output
      |> String.split(" ")
      |> Enum.map(&String.codepoints/1)
      |> Enum.map(&Enum.sort/1)
      |> find_nums(segments_a)
      |> IO.inspect()
      |> swap_keys()
      |> IO.inspect()

    output
    |> String.split(" ")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(&Enum.sort/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(fn v -> Integer.to_string(segments[v]) end)
    |> Enum.join()
    |> String.to_integer()
  end

  defp find_nums(signals, segments) do
    segments
    |> find_1478(signals)
    |> find_6(signals)
    |> find_3(signals)
    |> find_5(signals)
    |> find_2(signals)
    |> find_9(signals)
    |> find_0(signals)
  end

  defp swap_keys(nums_to_letters) do
    Enum.reduce(nums_to_letters, %{}, fn {k, v}, m -> Map.put(m, v, k) end)
  end

  defp find_1478(segments, signals) do
    Enum.reduce(
      signals,
      segments,
      fn chunk, seg -> find_unique(chunk, seg) end
    )
  end

  defp find_6(segments, signals) do
    # length 6, missing part of 1
    if is_nil(segments[6]) and !is_nil(segments[1]) do
      chunk6 =
        signals
        |> Enum.filter(fn l -> length(l) == 6 end)
        |> Enum.filter(fn l -> length(list_intersect(l, String.codepoints(segments[1]))) == 1 end)
        |> Enum.join()

      Map.put(segments, 6, chunk6)
    else
      segments
    end
  end

  defp find_3(segments, signals) do
    # length 5, completely contains 1
    if is_nil(segments[3]) do
      chunk3 =
        signals
        |> Enum.filter(fn l -> length(l) == 5 end)
        |> Enum.filter(fn l -> length(list_intersect(String.codepoints(segments[1]), l)) == 2 end)
        |> Enum.join()

      Map.put(segments, 3, chunk3)
    else
      segments
    end
  end

  defp find_5(segments, signals) do
    # length 5, completely contained in 6
    if is_nil(segments[5]) do
      chunk5 =
        signals
        |> Enum.filter(fn l -> length(l) == 5 end)
        |> Enum.filter(fn l -> length(list_intersect(String.codepoints(segments[6]), l)) == 5 end)
        |> Enum.join()

      Map.put(segments, 5, chunk5)
    else
      segments
    end
  end

  defp find_2(segments, signals) do
    # length 5, not equal to 3 or 5
    if is_nil(segments[2]) do
      chunk2 =
        signals
        |> Enum.filter(fn l -> length(l) == 5 end)
        |> Enum.map(&Enum.join/1)
        |> Enum.filter(fn l ->
          l != segments[5] and l != segments[3]
        end)

      if length(chunk2) > 0 do
        Map.put(segments, 2, hd(chunk2))
      else
        segments
      end
    else
      segments
    end
  end

  defp find_9(segments, signals) do
    # length 6, completely contains 4
    if is_nil(segments[9]) do
      chunk9 =
        signals
        |> Enum.filter(fn l -> length(l) == 6 end)
        |> Enum.filter(fn l -> length(list_intersect(l, String.codepoints(segments[4]))) == 4 end)
        |> Enum.join()

      Map.put(segments, 9, chunk9)
    else
      segments
    end
  end

  defp find_0(segments, signals) do
    # length 6, not equal to 9 or 6
    if is_nil(segments[0]) do
      chunk0 =
        signals
        |> Enum.filter(fn l -> length(l) == 6 end)
        |> Enum.map(&Enum.join/1)
        |> Enum.filter(fn l ->
          l != segments[9] and l != segments[6]
        end)

      if length(chunk0) > 0 do
        Map.put(segments, 0, hd(chunk0))
      else
        segments
      end
    else
      segments
    end
  end

  def find_unique(signal, segments) when length(signal) == 2 do
    sorted = signal |> Enum.sort() |> Enum.join()
    Map.put(segments, 1, sorted)
  end

  def find_unique(signal, segments) when length(signal) == 3 do
    sorted = signal |> Enum.sort() |> Enum.join()
    Map.put(segments, 7, sorted)
  end

  def find_unique(signal, segments) when length(signal) == 4 do
    sorted = signal |> Enum.sort() |> Enum.join()
    Map.put(segments, 4, sorted)
  end

  def find_unique(signal, segments) when length(signal) == 7 do
    sorted = signal |> Enum.sort() |> Enum.join()
    Map.put(segments, 8, sorted)
  end

  def find_unique(_signal, segments) do
    segments
  end

  defp list_intersect(list_a, list_b) do
    Enum.filter(list_a, fn l -> l in list_b end)
  end
end

# segments
# 0 -> 6 segments
# 1 -> 2 segments
# 2 -> 5 segments
# 3 -> 5 segments
# 4 -> 4 segments
# 5 -> 5 segments
# 6 -> 6 segments
# 7 -> 3 segments
# 8 -> 7 segments
# 9 -> 6 segments

# by segment
# 2: 1
# 3: 7
# 4: 4
# 5: 2, 3, 5
# 6: 0, 6, 9
# 7: 8

# by chunk
# top           0, 2, 3, 5, 6, 7, 8, 9
# top right     0, 1, 2, 3, 4, 7, 8, 9
# bottom right  0, 1, 3, 4, 5, 6, 7, 8, 9
# bottom        0, 2, 3, 5, 6, 8, 9
# bottom left   0, 2, 6, 8
# top left      0, 4, 5, 6, 8, 9
# middle        2, 3, 4, 5, 6, 8, 9

# 2 segments = 1
# 3 segments = 7
# 4 segments = 4
# 8 segments = 8
# 6 segments that is missing a piece of 1 => 6
# 5 segments that completely overlaps with 1 => 3
# 5 segments that completely overlap with 6 => 5
# remaining 5 segment one is 2

# 6 segments that includes 1 => 0 or 9
# using 6 and 7, we can narrow down 0 => middle piece
