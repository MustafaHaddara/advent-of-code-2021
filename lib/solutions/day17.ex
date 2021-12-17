defmodule Day17 do
  @test_input [
    "target area: x=20..30, y=-10..-5"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    bounds = parse(hd(input))

    find_highest_trajectory(bounds)
  end

  def solve(input, _part = "b") do
    bounds = parse(hd(input))

    count_valid_trajectories(bounds)
  end

  # part 2 all trajectories
  defp count_valid_trajectories(bounds) do
    # pick a initial trajectory somehow
    # works, 17, -4 doesn't

    get_velocities(bounds)
    |> Enum.map(fn v ->
      x = 0
      y = 0
      get_max_height({x, y}, v, bounds, y)
    end)
    |> Enum.filter(fn h -> !is_nil(h) end)
    |> Enum.count()
  end

  # part 1 highest trajectory
  defp find_highest_trajectory(bounds) do
    # pick a initial trajectory somehow
    # works, 17, -4 doesn't

    get_velocities(bounds)
    |> Enum.map(fn v ->
      x = 0
      y = 0
      get_max_height({x, y}, v, bounds, y)
    end)
    |> Enum.filter(fn h -> !is_nil(h) end)
    |> Enum.max()
  end

  defp get_velocities({{_min_x, min_y}, {max_x, _max_y}}) do
    0..max_x
    |> Enum.flat_map(fn vx ->
      min_y..(-1 * min_y) |> Enum.map(fn vy -> {vx, vy} end)
    end)
  end

  defp get_max_height({px, py}, _v, {{min_x, min_y}, {max_x, max_y}}, max_height)
       when px >= min_x and px <= max_x and py >= min_y and py <= max_y do
    # we're in the zone
    max_height
  end

  defp get_max_height({px, py}, _v, {{_min_x, min_y}, {max_x, _max_y}}, _max_height)
       when px > max_x or py < min_y do
    # we overshot
    nil
  end

  defp get_max_height({px, py}, v, bounds, max_height) do
    {{new_px, new_py}, new_v} = next_step({px, py}, v)
    new_max_h = max(max_height, new_py)
    get_max_height({new_px, new_py}, new_v, bounds, new_max_h)
  end

  defp next_step({px, py}, {vx, vy}) do
    d_vx = if vx == 0, do: 0, else: -1 * round(vx / abs(vx))

    {
      {px + vx, py + vy},
      {vx + d_vx, vy - 1}
    }
  end

  # parsing
  defp parse(input_row) do
    [_, _, x_spec, y_spec] = String.split(input_row, " ")
    [min_x, max_x] = parse_spec(x_spec)
    [min_y, max_y] = parse_spec(y_spec)

    {
      {min_x, min_y},
      {max_x, max_y}
    }
  end

  defp parse_spec(spec) do
    no_comma = hd(String.split(spec, ","))
    [_, vals] = String.split(no_comma, "=")
    vals |> String.split("..") |> Enum.map(&String.to_integer/1)
  end
end
