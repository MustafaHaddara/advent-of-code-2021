defmodule AdventOfCode do
  def main(args) do
    [day, part] = args

    {:ok, input_file} = File.read("inputs/day#{day}.txt")
    module = String.to_existing_atom("Elixir.Day#{day}")
    result = apply(module, :solve, [input_file, part])
    IO.puts(result)
  end
end
