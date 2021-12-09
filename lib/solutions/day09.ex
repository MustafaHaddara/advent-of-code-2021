defmodule Day9 do
  @test_input [
    "2199943210",
    "3987894921",
    "9856789892",
    "8767896789",
    "9899965678"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    max_row = length(input) - 1
    max_col = String.length(hd(input)) - 1

    0..max_row
    |> Enum.map(fn row ->
      0..max_col
      |> Enum.map(fn col ->
        x = String.at(Enum.at(input, row), col)

        if is_minimum(input, x, row, col) do
          String.to_integer(x) + 1
        else
          0
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def solve(input, _part = "b") do
    max_row = length(input) - 1
    max_col = String.length(hd(input)) - 1

    0..max_row
    |> Enum.flat_map(fn row ->
      0..max_col
      |> Enum.map(fn col ->
        x = String.at(Enum.at(input, row), col)

        if is_minimum(input, x, row, col) do
          {row, col}
        else
          nil
        end
      end)
    end)
    |> Enum.filter(fn x -> !is_nil(x) end)
    |> Enum.map(fn {row, col} -> fill_basin(%{}, row, col, input, max_row, max_col) end)
    |> Enum.map(&map_size/1)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.product()
  end

  defp fill_basin(basin, row, col, _input, max_row, max_col)
       when row < 0 or row > max_row or col < 0 or col > max_col do
    basin
  end

  defp fill_basin(basin, row, col, input, max_row, max_col) do
    x = String.at(Enum.at(input, row), col)

    if x == "9" or Map.get(basin, {row, col}) do
      basin
    else
      basin
      |> Map.put({row, col}, true)
      |> fill_basin(row + 1, col, input, max_row, max_col)
      |> fill_basin(row - 1, col, input, max_row, max_col)
      |> fill_basin(row, col + 1, input, max_row, max_col)
      |> fill_basin(row, col - 1, input, max_row, max_col)
    end
  end

  defp is_minimum(input, c, row, col) do
    [
      &above/3,
      &below/3,
      &left/3,
      &right/3
    ]
    |> Enum.all?(fn cb ->
      r = cb.(input, row, col)
      is_nil(r) || String.to_integer(r) > String.to_integer(c)
    end)
  end

  defp above(_input, row, _col) when row == 0 do
    nil
  end

  defp above(input, row, col) do
    String.at(Enum.at(input, row - 1), col)
  end

  defp below(input, row, _col) when length(input) - 1 == row do
    nil
  end

  defp below(input, row, col) do
    String.at(Enum.at(input, row + 1), col)
  end

  defp left(_input, _row, col) when col == 0 do
    nil
  end

  defp left(input, row, col) do
    String.at(Enum.at(input, row), col - 1)
  end

  defp right(input, _row, col) when length(hd(input)) - 1 == col do
    nil
  end

  defp right(input, row, col) do
    String.at(Enum.at(input, row), col + 1)
  end
end
