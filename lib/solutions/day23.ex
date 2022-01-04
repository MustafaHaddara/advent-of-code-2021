defmodule Day23 do
  @test_input [
    "#############",
    "#...........#",
    "###B#C#B#D###",
    "  #A#D#C#A#",
    "  #########"
  ]

  @costs %{
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000
  }

  @connections %{
    "A" => 2,
    "B" => 4,
    "C" => 6,
    "D" => 8
  }

  # verbosity levels: 0, 1, or 2
  @logging 0

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    {rooms, hallway} = parse_input(input)

    {min_cost, _} = explore(rooms, hallway, 0, 25_000, %{}, 0)

    min_cost
  end

  def solve(input, _part = "b") do
    to_insert = [
      "#D#C#B#A#",
      "#D#B#A#C#"
    ]

    updated_input = Enum.slice(input, 0..2) ++ to_insert ++ Enum.slice(input, 3..4)
    {rooms, hallway} = parse_input(updated_input)

    {min_cost, _} = explore(rooms, hallway, 0, 100_000, %{}, 0)

    min_cost
  end

  defp tokenize(rooms, hallway) do
    Enum.join(hallway) <>
      Enum.join(Map.get(rooms, "A")) <>
      Enum.join(Map.get(rooms, "B")) <>
      Enum.join(Map.get(rooms, "C")) <>
      Enum.join(Map.get(rooms, "D"))
  end

  defp explore(rooms, hallway, current_cost, min_cost, seen, indent) do
    token = tokenize(rooms, hallway)
    spacing = String.duplicate(" ", indent)

    if @logging >= 2 do
      IO.puts("#{spacing}#{token} - #{current_cost}")
    end

    if current_cost >= Map.get(seen, token) or current_cost >= min_cost do
      {min_cost, seen}
    else
      if is_complete(rooms, hallway) do
        # guaranteed current_cost < min_cost because of the check above
        if @logging >= 1 do
          IO.puts("complete with cost #{current_cost}")
        end

        {current_cost, seen}
      else
        new_seen = Map.put(seen, token, current_cost)
        # if anyone's in the hallway AND their target room is free
        # we can go there
        {min_hallway_cost, hallway_seen} =
          hallway
          |> Enum.with_index()
          |> Enum.filter(fn {c, _} -> c != "." end)
          |> Enum.filter(fn {c, idx} -> can_enter(c, idx, hallway, rooms) end)
          |> Enum.reduce({min_cost, new_seen}, fn {to_move, i},
                                                  {inner_min_cost, inner_new_seen} ->
            if @logging >= 2 do
              IO.puts("#{spacing}-- hallway --")
              token = tokenize(rooms, hallway)
              IO.puts("#{spacing}#{token} - #{current_cost}")
            end

            # new hallway
            new_hallway = List.replace_at(hallway, i, ".")

            # new rooms
            target_room = Map.get(rooms, to_move)
            target_room_idx = get_target_idx_in_room(target_room, length(target_room) - 1)
            new_room = List.replace_at(target_room, target_room_idx, to_move)
            new_rooms = Map.put(rooms, to_move, new_room)

            # cost to move into the room
            hallway_cost = abs(Map.get(@connections, to_move) - i)
            step_cost = Map.get(@costs, to_move) * (hallway_cost + target_room_idx + 1)

            if @logging >= 2 do
              token = tokenize(new_rooms, new_hallway)
              IO.puts("#{spacing}#{token} - #{current_cost + step_cost}")
              IO.puts("#{spacing}-- hallway --")
            end

            explore(
              new_rooms,
              new_hallway,
              current_cost + step_cost,
              inner_min_cost,
              inner_new_seen,
              indent + 2
            )
          end)

        # if anyone's in a room, enumerate all of the states they can go to
        {min_room_cost, room_seen} =
          rooms
          |> Enum.filter(fn {target, room} -> not is_room_done(target, room) end)
          |> Enum.filter(fn {_, room} -> not is_room_empty(room) end)
          |> Enum.reduce({min_hallway_cost, hallway_seen}, fn {c, room},
                                                              {inner_min_cost, inner_seen} ->
            explore_rooms(
              room,
              c,
              rooms,
              hallway,
              current_cost,
              inner_min_cost,
              inner_seen,
              indent
            )
          end)

        {min_room_cost, room_seen}
      end
    end
  end

  defp explore_rooms(room, c, rooms, hallway, current_cost, min_cost, seen, indent) do
    spacing = String.duplicate(" ", indent)

    # new rooms
    {to_move, idx} = get_room_stats(room, 0)
    new_room = List.replace_at(room, idx, ".")
    new_rooms = Map.put(rooms, c, new_room)

    steps_out = idx + 1

    hallway_intersection = Map.get(@connections, c)

    hallway_indices =
      find_hallway_indices_from_room(hallway, hallway_intersection)
      |> Enum.filter(fn idx -> idx not in Map.values(@connections) end)

    hallway_indices
    |> Enum.reduce({min_cost, seen}, fn idx, {inner_min_cost, inner_seen} ->
      if @logging >= 2 do
        IO.puts("#{spacing}-- room --")
        token = tokenize(rooms, hallway)
        IO.puts("#{spacing}#{token} - #{current_cost}")
      end

      new_hallway = List.replace_at(hallway, idx, to_move)

      hallway_steps = abs(hallway_intersection - idx)
      total_steps = steps_out + hallway_steps
      step_cost = Map.get(@costs, to_move) * total_steps

      if @logging >= 2 do
        token = tokenize(new_rooms, new_hallway)
        IO.puts("#{spacing}#{token} - #{current_cost + step_cost}")
        IO.puts("#{spacing}-- room --")
      end

      explore(
        new_rooms,
        new_hallway,
        current_cost + step_cost,
        inner_min_cost,
        inner_seen,
        indent + 2
      )
    end)
  end

  defp is_room_done(target, [first | _rest]) when first != target do
    false
  end

  defp is_room_done(_target, []) do
    true
  end

  defp is_room_done(target, [_first | rest]) do
    is_room_done(target, rest)
  end

  defp is_room_empty(room) do
    Enum.all?(room, fn c -> c == "." end)
  end

  defp get_room_stats([to_move | rest], idx) do
    if to_move != "." do
      {to_move, idx}
    else
      get_room_stats(rest, idx + 1)
    end
  end

  defp find_hallway_indices_from_room(hallway, current_idx) do
    [current_idx] ++
      find_hallway_indices_from_room(hallway, current_idx, +1) ++
      find_hallway_indices_from_room(hallway, current_idx, -1)
  end

  defp find_hallway_indices_from_room(hallway, current_idx, dir) do
    next_idx = current_idx + dir

    if next_idx < 0 or next_idx >= length(hallway) or Enum.at(hallway, next_idx) != "." do
      []
    else
      [next_idx | find_hallway_indices_from_room(hallway, next_idx, dir)]
    end
  end

  defp is_complete(rooms, hallway) do
    hallway_empty = Enum.all?(hallway, fn c -> c == "." end)

    rooms_done =
      rooms
      |> Enum.all?(fn {target, room} -> Enum.all?(room, fn c -> c == target end) end)

    rooms_done and hallway_empty
  end

  defp get_target_idx_in_room(room, idx) do
    if Enum.at(room, idx) == "." do
      idx
    else
      get_target_idx_in_room(room, idx - 1)
    end
  end

  defp can_enter(c, idx, hallway, rooms) do
    target = Map.get(@connections, c)

    hallway_free =
      idx..target
      |> Enum.filter(fn i -> i != idx end)
      |> Enum.all?(fn i -> Enum.at(hallway, i) == "." end)

    target_room = Map.get(rooms, c)
    room_free = target_room |> Enum.all?(fn char -> char == "." || char == c end)

    hallway_free and room_free
  end

  defp parse_input(input) do
    rooms =
      input
      |> Enum.slice(2..(length(input) - 2))
      |> Enum.map(fn row ->
        row
        |> String.codepoints()
        |> Enum.filter(fn c -> c != "#" and c != " " end)
      end)
      |> Enum.zip()
      |> Enum.map(fn t -> Tuple.to_list(t) end)
      |> Enum.with_index()
      |> Enum.map(fn {room, idx} ->
        %{
          room: room,
          connection: (idx + 1) * 2,
          target: Enum.at(["A", "B", "C", "D"], idx)
        }
      end)
      |> Enum.reduce(%{}, fn o, all -> Map.put(all, o.target, o.room) end)

    hallway =
      input
      |> Enum.at(1)
      |> String.codepoints()
      |> Enum.filter(fn c -> c == "." end)

    {rooms, hallway}
  end
end
