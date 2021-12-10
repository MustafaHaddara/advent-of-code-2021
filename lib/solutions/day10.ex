defmodule Day10 do
  @test_input [
    "[({(<(())[]>[[{[]{<()<>>",
    "[(()[<>])]({[<{<<[]>>(",
    "{([(<{}[<>[]}>{[]{[(<()>",
    "(((({<>}<{<{<>}{[]{[]{}",
    "[[<[([]))<([[{}[[()]]]",
    "[{[{({}]{}}([{[{{{}}([]",
    "{<[[]]>}<{[{[{[]{()[[[]",
    "[<(<(<(<{}))><([]([]()",
    "<{([([[(<>()){}]>(<<{{",
    "<{([{{}}[<[[[<>{}]]]>[]]"
  ]

  @points_1 %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  @points_2 %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }

  @matches %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    input
    |> Enum.map(fn line -> syntax_check_line(line) end)
    |> Enum.filter(fn invalid_char -> !is_nil(invalid_char) end)
    |> Enum.map(fn invalid_char -> Map.get(@points_1, invalid_char) end)
    |> Enum.sum()
  end

  def solve(input, _part = "b") do
    sorted =
      input
      |> Enum.map(fn line -> get_remaining(line) end)
      |> Enum.filter(fn remaining -> !is_nil(remaining) end)
      |> Enum.map(fn remaining ->
        remaining
        |> Enum.map(fn c -> Map.get(@points_2, c) end)
        |> Enum.reduce(fn num, total -> total * 5 + num end)
      end)
      |> Enum.sort()

    Enum.at(sorted, round(length(sorted) / 2) - 1)
  end

  # part 1
  defp syntax_check_line(line) do
    stack = []

    match_letter(String.codepoints(line), stack)
  end

  defp match_letter([current | rest_letters], stack) do
    matching = Map.get(@matches, current)

    if is_nil(matching) do
      [expected | rest_seen] = stack

      if current == expected do
        match_letter(rest_letters, rest_seen)
      else
        current
      end
    else
      match_letter(rest_letters, [matching | stack])
    end
  end

  defp match_letter([], _stack) do
    nil
  end

  # part 2
  defp get_remaining(line) do
    stack = []

    get_expected_stack(String.codepoints(line), stack)
  end

  defp get_expected_stack([current | rest_letters], stack) do
    matching = Map.get(@matches, current)

    if is_nil(matching) do
      [expected | rest_seen] = stack

      if current == expected do
        get_expected_stack(rest_letters, rest_seen)
      else
        nil
      end
    else
      get_expected_stack(rest_letters, [matching | stack])
    end
  end

  defp get_expected_stack([], stack) do
    stack
  end
end
