defmodule AdventOfCode do
  def main() do
    [_, day, part] = System.argv()

    {:ok, input_file} = File.read("inputs/day#{day}.txt")
    module = String.to_existing_atom("Elixir.Day#{day}")
    result = apply(module, :solve, [input_file, part])
    IO.puts(result)
  end
end
