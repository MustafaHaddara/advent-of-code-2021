defmodule Day4 do
  @test_input [
    "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1",
    "",
    "22 13 17 11  0",
    "8  2 23  4 24",
    "21  9 14 16  7",
    "6 10  3 18  5",
    "1 12 20 15 19",
    "",
    "3 15  0  2 22",
    "9 18 13 17  5",
    "19  8  7 25 23",
    "20 11 10 24  4",
    "14 21 16 12  6",
    "",
    "14 21 17 24  4",
    "10 16 15  9 19",
    "18  8 23 26 20",
    "22 11 13  6  5",
    "2  0 12  3  7"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    {nums, boards} = parse_input(input)
    {winning_board, last_num} = get_winning_board(boards, nums)
    total = score_board(winning_board)
    total * last_num
  end

  def solve(input, _part = "b") do
    {nums, boards} = parse_input(input)
    {winning_board, last_num} = get_last_winning_board(boards, nums)
    total = score_board(winning_board)
    total * last_num
  end

  # part 1
  defp get_winning_board(boards, [num | rest]) do
    next_boards = mark(boards, num)
    winner = Enum.find(next_boards, fn b -> is_winning_board(b) end)

    case winner do
      nil -> get_winning_board(next_boards, rest)
      _ -> {winner, num}
    end
  end

  defp get_last_winning_board(boards, [num | rest]) do
    next_boards = mark(boards, num)
    remaining = Enum.filter(next_boards, fn b -> !is_winning_board(b) end)

    case length(remaining) do
      0 -> {hd(next_boards), num}
      _ -> get_last_winning_board(remaining, rest)
    end
  end

  # parsing
  defp parse_input([first, _blank | rest]) do
    nums =
      first
      |> String.split(",")
      |> Enum.map(fn x -> String.to_integer(x, 10) end)

    boards = parse_boards(rest, [], [])
    {nums, boards}
  end

  defp parse_boards([row_str | rest], boards, current_board) when row_str == "" do
    parse_boards(rest, [current_board | boards], [])
  end

  defp parse_boards([row_str | rest], boards, current_board) do
    row = parse_row(row_str)
    parse_boards(rest, boards, [row | current_board])
  end

  defp parse_boards([], boards, current_board) do
    [current_board | boards]
  end

  defp parse_row(r) do
    r
    |> String.split(" ")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn x -> String.to_integer(x, 10) end)
  end

  # iterating
  defp mark(boards, num) do
    Enum.map(boards, fn b -> mark_board(b, num) end)
  end

  defp mark_board(board, num) do
    Enum.map(board, fn b -> mark_rows(b, num) end)
  end

  defp mark_rows(rows, num) do
    Enum.map(rows, fn x -> if x == num, do: nil, else: x end)
  end

  # check winning
  defp is_winning_board(board) do
    winning_row = is_winning_board_rows(board)

    if winning_row do
      true
    else
      is_winning_board_cols(board, 0)
    end
  end

  defp is_winning_board_rows([row | rest]) do
    len = row |> Enum.filter(fn x -> !is_nil(x) end) |> length()

    case len do
      0 -> true
      _ -> is_winning_board_rows(rest)
    end
  end

  defp is_winning_board_rows([]) do
    false
  end

  defp is_winning_board_cols(_board, col) when col == 5 do
    false
  end

  defp is_winning_board_cols(board, col) do
    won = is_winning_board_col(board, col)

    case won do
      true -> true
      false -> is_winning_board_cols(board, col + 1)
    end
  end

  defp is_winning_board_col([row | rest], col) do
    item = Enum.at(row, col)

    case item do
      nil -> is_winning_board_col(rest, col)
      _ -> false
    end
  end

  defp is_winning_board_col([], _col) do
    true
  end

  defp score_board([row | rest]) do
    row_total =
      row
      |> Enum.filter(fn x -> !is_nil(x) end)
      |> Enum.sum()

    row_total + score_board(rest)
  end

  defp score_board([]) do
    0
  end
end
