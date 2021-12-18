require Integer

defmodule Day18 do
  @test_input [
    "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]",
    "[[[5,[2,8]],4],[5,[[9,9],0]]]",
    "[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]",
    "[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]",
    "[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]",
    "[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]",
    "[[[[5,4],[7,7]],8],[[8,3],8]]",
    "[[9,3],[[9,9],[6,[4,9]]]]",
    "[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]",
    "[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    [first | rest] =
      input
      |> Enum.map(fn row -> parse_row(row) end)

    rest
    |> Enum.reduce(first, fn num, total ->
      add(total, num)
    end)
    |> magnitude()
  end

  def solve(input, _part = "b") do
    numbers =
      input
      |> Enum.map(fn row -> parse_row(row) end)

    numbers
    |> Enum.with_index()
    |> Enum.flat_map(fn {number, i} ->
      numbers
      |> Enum.with_index()
      |> Enum.filter(fn {_, j} -> i != j end)
      |> Enum.map(fn {other, _} ->
        add(number, other)
      end)
      |> Enum.map(fn n -> magnitude(n) end)
    end)
    |> Enum.max()
  end

  defp parse_row(row) do
    {num, _} = parse_snailfish_number(String.codepoints(row))
    num
  end

  defp parse_snailfish_number([char | rest]) do
    case char do
      "[" ->
        {left, remaining} = parse_snailfish_number(rest)
        {right, remaining} = parse_snailfish_number(remaining)
        ["]" | unparsed] = remaining
        {%{left: left, right: right}, unparsed}

      "]" ->
        parse_snailfish_number(rest)

      " " ->
        parse_snailfish_number(rest)

      "," ->
        parse_snailfish_number(rest)

      c ->
        {%{value: String.to_integer(c)}, rest}
    end
  end

  defp add(a, b) do
    reduce(%{
      left: a,
      right: b
    })
  end

  defp reduce(number) do
    {a, exploded?} = explode(number)

    if exploded? do
      reduce(a)
    else
      {b, split?} = split(a)

      if split? do
        reduce(b)
      else
        b
      end
    end
  end

  # explode
  defp explode(number) do
    {result, _, exploded?} = explode(number, 0)
    {result, exploded?}
  end

  defp explode(%{value: v}, _) do
    {%{value: v}, %{left: nil, right: nil}, false}
  end

  defp explode(%{left: %{value: left}, right: %{value: right}}, depth) when depth == 4 do
    {%{value: 0}, %{left: left, right: right}, true}
  end

  defp explode(%{left: left, right: right}, depth) do
    # explode left
    {new_left, %{left: child_left, right: child_right}, exploded?} = explode(left, depth + 1)

    if exploded? do
      new_right =
        if is_nil(child_right), do: right, else: add_to_leftmost_child(right, child_right)

      # return
      {%{left: new_left, right: new_right}, %{left: child_left, right: nil}, exploded?}
    else
      # explode right
      {new_right, %{left: child_left, right: child_right}, exploded?} = explode(right, depth + 1)

      new_left = if is_nil(child_left), do: left, else: add_to_rightmost_child(left, child_left)

      {%{left: new_left, right: new_right}, %{left: nil, right: child_right}, exploded?}
    end
  end

  defp add_to_rightmost_child(%{value: value}, to_add) do
    %{value: value + to_add}
  end

  defp add_to_rightmost_child(%{left: left, right: right}, to_add) do
    %{left: left, right: add_to_rightmost_child(right, to_add)}
  end

  defp add_to_leftmost_child(%{value: value}, to_add) do
    %{value: value + to_add}
  end

  defp add_to_leftmost_child(%{left: left, right: right}, to_add) do
    %{left: add_to_leftmost_child(left, to_add), right: right}
  end

  defp split(%{left: left, right: right}) do
    {new_left, left_split?} = split(left)
    {new_right, right_split?} = if left_split?, do: {right, false}, else: split(right)
    {%{left: new_left, right: new_right}, left_split? or right_split?}
  end

  defp split(%{value: number}) when number >= 10 do
    left = Integer.floor_div(number, 2)
    right = if Integer.is_even(number), do: left, else: left + 1
    {%{left: %{value: left}, right: %{value: right}}, true}
  end

  defp split(%{value: number}) do
    {%{value: number}, false}
  end

  # magnitude
  defp magnitude(%{left: left, right: right}) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  defp magnitude(%{value: value}) do
    value
  end

  # debugging
  defp inspect_row(row) do
    row
    |> row_to_string()
    |> IO.puts()

    row
  end

  defp row_to_string(%{left: left, right: right}) do
    "[" <> row_to_string(left) <> ", " <> row_to_string(right) <> "]"
  end

  defp row_to_string(%{value: value}) do
    Integer.to_string(value)
  end
end
