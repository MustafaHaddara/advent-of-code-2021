defmodule Mix.Tasks.Solve do
  @moduledoc "The solve mix task: `mix help solve`"
  use Mix.Task

  @shortdoc "Solves the problem."
  def run(_) do
    AdventOfCode.main()
  end
end
