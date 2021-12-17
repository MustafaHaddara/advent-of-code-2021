defmodule Day16 do
  @test_input [
    "D8005AC2A8F0"
  ]

  @bin_map %{
    "0" => "0000",
    "1" => "0001",
    "2" => "0010",
    "3" => "0011",
    "4" => "0100",
    "5" => "0101",
    "6" => "0110",
    "7" => "0111",
    "8" => "1000",
    "9" => "1001",
    "A" => "1010",
    "B" => "1011",
    "C" => "1100",
    "D" => "1101",
    "E" => "1110",
    "F" => "1111"
  }

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    bits =
      input
      |> hd()
      |> String.codepoints()
      |> Enum.map(fn c -> Map.get(@bin_map, c) end)
      |> Enum.join()
      |> String.codepoints()

    {ops, _} = parse_bits(bits)

    sum_versions(ops)
  end

  def solve(input, _part = "b") do
    bits =
      input
      |> hd()
      |> String.codepoints()
      |> Enum.map(fn c -> Map.get(@bin_map, c) end)
      |> Enum.join()
      |> String.codepoints()

    {ops, _} = parse_bits(bits)
    eval(ops)
  end

  def eval(op) when op.type == 4 do
    op.value
  end

  def eval(op) when op.type == 0 do
    op.children |> Enum.map(fn o -> eval(o) end) |> Enum.sum()
  end

  def eval(op) when op.type == 1 do
    op.children |> Enum.map(fn o -> eval(o) end) |> Enum.product()
  end

  def eval(op) when op.type == 2 do
    op.children |> Enum.map(fn o -> eval(o) end) |> Enum.min()
  end

  def eval(op) when op.type == 3 do
    op.children |> Enum.map(fn o -> eval(o) end) |> Enum.max()
  end

  def eval(op) when op.type == 5 do
    [first, second] = op.children

    if eval(first) > eval(second) do
      1
    else
      0
    end
  end

  def eval(op) when op.type == 6 do
    [first, second] = op.children

    if eval(first) < eval(second) do
      1
    else
      0
    end
  end

  def eval(op) when op.type == 7 do
    [first, second] = op.children

    if eval(first) == eval(second) do
      1
    else
      0
    end
  end

  def sum_versions(op) do
    if Map.has_key?(op, :children) do
      children_val =
        Map.get(op, :children)
        |> Enum.map(fn o -> sum_versions(o) end)
        |> Enum.sum()

      Map.get(op, :version) + children_val
    else
      Map.get(op, :version)
    end
  end

  defp parse_bits(bits) do
    # header
    {version, rest} = parse_n(bits, 3, "")
    {type, body} = parse_n(rest, 3, "")

    parse_body(version, type, body, [])
  end

  defp parse_body(version, type, [b0, b1, b2, b3, b4 | rest], result) when type == 4 do
    num = [b1, b2, b3, b4] |> Enum.join()

    if b0 == "1" do
      parse_body(version, type, rest, [num | result])
    else
      num = [num | result] |> Enum.reverse() |> Enum.join()

      packet = %{
        :version => version,
        :type => type,
        :value => String.to_integer(num, 2)
      }

      {packet, rest}
    end
  end

  defp parse_body(version, type, [length_id | rest], _result) when type != 4 do
    {subpackets, remaining_bits} =
      if length_id == "0",
        do: parse_children_by_length(rest),
        else: parse_children_by_number(rest)

    packet = %{
      :version => version,
      :type => type,
      :children => subpackets
    }

    {packet, remaining_bits}
  end

  # parse children by length of bits
  defp parse_children_by_length(bits) do
    {length, rest} = parse_n(bits, 15, "")
    {to_parse, rest} = split_list(rest, length, [])
    children = parse_children_by_length_chunk(to_parse)
    {children, rest}
  end

  defp parse_children_by_length_chunk([]) do
    []
  end

  defp parse_children_by_length_chunk(chunk) do
    {packet, rest} = parse_bits(chunk)
    [packet | parse_children_by_length_chunk(rest)]
  end

  # parse children by number of children
  defp parse_children_by_number(bits) do
    {number, rest} = parse_n(bits, 11, "")
    parse_children_by_number(rest, [], number)
  end

  defp parse_children_by_number(bits, result, 0) do
    {Enum.reverse(result), bits}
  end

  defp parse_children_by_number(bits, result, n) do
    {packet, rest} = parse_bits(bits)
    parse_children_by_number(rest, [packet | result], n - 1)
  end

  # utils
  defp parse_n(bits, n, result) when n == 0 do
    {String.reverse(result) |> String.to_integer(2), bits}
  end

  defp parse_n([first | rest], n, result) do
    parse_n(rest, n - 1, first <> result)
  end

  defp split_list(ls, n, result) when n == 0 do
    {Enum.reverse(result), ls}
  end

  defp split_list([first | rest], n, result) do
    split_list(rest, n - 1, [first | result])
  end
end
