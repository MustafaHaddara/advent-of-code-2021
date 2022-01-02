defmodule Day24 do
  @test_input [
    "inp z",
    "inp x",
    "mul z 3",
    "mul z -1",
    "add z 20",
    "mod z 5"
    # "eql z x"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  # read the instructions, derived the following constraints:
  # d1+8 = d14
  # d2+7 = d13
  # d3-6 = d4
  # d5+5 = d6
  # d7-8 = d12
  # d8+1 = d11
  # d9-5 = d10

  def solve(input, _part = "a") do
    check_if_valid(input, 12_934_998_949_199)
  end

  def solve(input, _part = "b") do
    check_if_valid(input, 11_711_691_612_189)
  end

  def check_if_valid(input, value) do
    digits = Integer.digits(value)
    {res, _} = begin_eval(input, digits)

    if Map.get(res, "z") == 0 do
      value
    else
      IO.puts("not valid!")
      nil
    end
  end

  def begin_eval(instructions, input) do
    vars = %{
      "w" => 0,
      "x" => 0,
      "y" => 0,
      "z" => 0
    }

    eval(instructions, vars, input)
  end

  def eval(instructions, vars, input) do
    Enum.reduce(instructions, {vars, input}, fn line, {vars, input} ->
      [ins | args] = String.split(line, " ")
      {nvars, ninput} = eval_instruction(ins, args, vars, input)

      {nvars, ninput}
    end)
  end

  defp eval_instruction(ins, [target], vars, [val | rest_input]) when ins == "inp" do
    new_vars = Map.put(vars, target, val)

    {new_vars, rest_input}
  end

  defp eval_instruction(ins, args, vars, input) when ins == "add" do
    target = hd(args)
    [a, b] = get_a_b(args, vars)
    result = a + b
    new_vars = Map.put(vars, target, result)

    {new_vars, input}
  end

  defp eval_instruction(ins, args, vars, input) when ins == "mul" do
    target = hd(args)
    [a, b] = get_a_b(args, vars)
    result = a * b
    new_vars = Map.put(vars, target, result)

    {new_vars, input}
  end

  defp eval_instruction(ins, args, vars, input) when ins == "div" do
    target = hd(args)
    [a, b] = get_a_b(args, vars)
    result = round_to_0(a / b)
    new_vars = Map.put(vars, target, result)

    {new_vars, input}
  end

  defp eval_instruction(ins, args, vars, input) when ins == "mod" do
    target = hd(args)
    [a, b] = get_a_b(args, vars)
    result = rem(a, b)
    new_vars = Map.put(vars, target, result)

    {new_vars, input}
  end

  defp eval_instruction(ins, args, vars, input) when ins == "eql" do
    target = hd(args)
    [a, b] = get_a_b(args, vars)
    result = if a == b, do: 1, else: 0
    new_vars = Map.put(vars, target, result)

    {new_vars, input}
  end

  defp get_a_b([raw_a, raw_b], vars) do
    a = Map.get(vars, raw_a)
    b = get_val_or_number(raw_b, vars)
    [a, b]
  end

  defp get_val_or_number(raw, vars) do
    case Integer.parse(raw) do
      {v, ""} -> v
      _ -> Map.get(vars, raw)
    end
  end

  defp round_to_0(val) do
    if val == floor(val) or val > 0 do
      floor(val)
    else
      floor(val) - 1
    end
  end
end
