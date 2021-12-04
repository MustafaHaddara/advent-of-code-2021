defmodule AdventOfCode do
  def main() do
    [_, day, part] = System.argv()

    {:ok, input_file} = File.read("inputs/day#{day}.txt")
    input_data = input_file |> String.split("\n")
    module = String.to_existing_atom("Elixir.Day#{day}")
    result = apply(module, :solve, [input_data, part])
    IO.puts(result)
  end

  def test() do
    [_, day, part] = System.argv()
    module = String.to_existing_atom("Elixir.Day#{day}")
    result = apply(module, :test, [part])
    IO.puts(result)
  end
end
