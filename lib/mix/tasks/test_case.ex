defmodule Mix.Tasks.TestCase do
  @moduledoc "The test_case mix task: `mix help test_case`"
  use Mix.Task

  @shortdoc "Runs the test case for the problem."
  @spec run(any) :: :ok
  def run(_) do
    AdventOfCode.test()
  end
end
