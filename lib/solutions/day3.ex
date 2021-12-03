use Bitwise

defmodule Day3 do
  @test_input [
    "00100",
    "11110",
    "10110",
    "10111",
    "10101",
    "01111",
    "00111",
    "11100",
    "10000",
    "11001",
    "00010",
    "01010"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    transpose(input)
  end

  def solve(input, _part = "b") do
    cp =
      input
      |> Enum.map(fn l -> String.codepoints(l) end)

    {o2, _} = filter_o2(cp, 0) |> to_string() |> Integer.parse(2)
    {co2, _} = filter_co2(cp, 0) |> to_string() |> Integer.parse(2)
    o2 * co2
  end

  defp transpose(lines) do
    gamma_list = most_common(lines)

    epsilon_list = binvert(gamma_list)

    {gamma, _} = Integer.parse(to_string(gamma_list), 2)
    {epsilon, _} = Integer.parse(to_string(epsilon_list), 2)
    gamma * epsilon
  end

  defp most_common(lines) do
    lines
    |> Enum.reduce(
      List.duplicate([], String.length(hd(lines))),
      fn line, acc -> transpose(String.to_charlist(line), acc) end
    )
    |> Enum.map(fn line -> choose_char(line) end)
  end

  # part 1
  defp transpose([first_char | rest_chars], [first_list | rest_lists]) do
    [[first_char | first_list] | transpose(rest_chars, rest_lists)]
  end

  defp transpose([], []) do
    []
  end

  defp choose_char(line) do
    [zeroes, ones] =
      Enum.reduce(line, [0, 0], fn x, [zeroes, ones] ->
        case x do
          48 -> [zeroes + 1, ones]
          49 -> [zeroes, ones + 1]
        end
      end)

    case zeroes > ones do
      true -> "0"
      false -> "1"
    end
  end

  defp binvert([first | rest]) when first == "1" do
    ["0" | binvert(rest)]
  end

  defp binvert([first | rest]) when first == "0" do
    ["1" | binvert(rest)]
  end

  defp binvert([]) do
    []
  end

  # part 2
  defp filter_o2(lines, idx) do
    filter_for_target(lines, idx, &most_common_in_pos/2)
  end

  defp filter_co2(lines, idx) do
    filter_for_target(lines, idx, &least_common_in_pos/2)
  end

  defp filter_for_target(lines, idx, target_func) do
    target = target_func.(lines, idx)

    next_lines =
      lines
      |> Enum.filter(fn l -> Enum.at(l, idx) == target end)

    case length(next_lines) do
      1 -> hd(next_lines)
      _ -> filter_for_target(next_lines, idx + 1, target_func)
    end
  end

  defp most_common_in_pos(l, idx) do
    [zeroes, ones] = freqs(l, idx)

    case zeroes > ones do
      true -> "0"
      false -> "1"
    end
  end

  defp least_common_in_pos(l, idx) do
    [zeroes, ones] = freqs(l, idx)

    case zeroes > ones do
      true -> "1"
      false -> "0"
    end
  end

  defp freqs(l, idx) do
    Enum.reduce(l, [0, 0], fn x, [zeroes, ones] ->
      case Enum.at(x, idx) do
        "0" -> [zeroes + 1, ones]
        "1" -> [zeroes, ones + 1]
      end
    end)
  end
end
