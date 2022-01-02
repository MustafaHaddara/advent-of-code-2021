defmodule Day19 do
  @test_input [
    "--- scanner 0 ---",
    "404,-588,-901",
    "528,-643,409",
    "-838,591,734",
    "390,-675,-793",
    "-537,-823,-458",
    "-485,-357,347",
    "-345,-311,381",
    "-661,-816,-575",
    "-876,649,763",
    "-618,-824,-621",
    "553,345,-567",
    "474,580,667",
    "-447,-329,318",
    "-584,868,-557",
    "544,-627,-890",
    "564,392,-477",
    "455,729,728",
    "-892,524,684",
    "-689,845,-530",
    "423,-701,434",
    "7,-33,-71",
    "630,319,-379",
    "443,580,662",
    "-789,900,-551",
    "459,-707,401",
    "",
    "--- scanner 1 ---",
    "686,422,578",
    "605,423,415",
    "515,917,-361",
    "-336,658,858",
    "95,138,22",
    "-476,619,847",
    "-340,-569,-846",
    "567,-361,727",
    "-460,603,-452",
    "669,-402,600",
    "729,430,532",
    "-500,-761,534",
    "-322,571,750",
    "-466,-666,-811",
    "-429,-592,574",
    "-355,545,-477",
    "703,-491,-529",
    "-328,-685,520",
    "413,935,-424",
    "-391,539,-444",
    "586,-435,557",
    "-364,-763,-893",
    "807,-499,-711",
    "755,-354,-619",
    "553,889,-390",
    "",
    "--- scanner 2 ---",
    "649,640,665",
    "682,-795,504",
    "-784,533,-524",
    "-644,584,-595",
    "-588,-843,648",
    "-30,6,44",
    "-674,560,763",
    "500,723,-460",
    "609,671,-379",
    "-555,-800,653",
    "-675,-892,-343",
    "697,-426,-610",
    "578,704,681",
    "493,664,-388",
    "-671,-858,530",
    "-667,343,800",
    "571,-461,-707",
    "-138,-166,112",
    "-889,563,-600",
    "646,-828,498",
    "640,759,510",
    "-630,509,768",
    "-681,-892,-333",
    "673,-379,-804",
    "-742,-814,-386",
    "577,-820,562",
    "",
    "--- scanner 3 ---",
    "-589,542,597",
    "605,-692,669",
    "-500,565,-823",
    "-660,373,557",
    "-458,-679,-417",
    "-488,449,543",
    "-626,468,-788",
    "338,-750,-386",
    "528,-832,-391",
    "562,-778,733",
    "-938,-730,414",
    "543,643,-506",
    "-524,371,-870",
    "407,773,750",
    "-104,29,83",
    "378,-903,-323",
    "-778,-728,485",
    "426,699,580",
    "-438,-605,-362",
    "-469,-447,-387",
    "509,732,623",
    "647,635,-688",
    "-868,-804,481",
    "614,-800,639",
    "595,780,-596",
    "",
    "--- scanner 4 ---",
    "727,592,562",
    "-293,-554,779",
    "441,611,-461",
    "-714,465,-776",
    "-743,427,-804",
    "-660,-479,-426",
    "832,-632,460",
    "927,-485,-438",
    "408,393,-506",
    "466,436,-512",
    "110,16,151",
    "-258,-428,682",
    "-393,719,612",
    "-211,-452,876",
    "808,-476,-593",
    "-575,615,604",
    "-485,667,467",
    "-680,325,-822",
    "-627,-443,-432",
    "872,-547,-609",
    "833,512,582",
    "807,604,487",
    "839,-516,451",
    "891,-625,532",
    "-652,-548,-490",
    "30,-46,-14"
  ]

  # half of these are invalid
  # which half? idk
  # but half of them break the internal logic of the coordinate system
  # fortunately, we can live with this
  defp transforms3() do
    directions()
    |> Enum.flat_map(fn d ->
      orientations()
      |> Enum.map(fn [o1, o2] ->
        [fn coord -> d.(o1.(coord)) end, fn coord -> o2.(d.(coord)) end]
      end)
    end)
  end

  defp directions() do
    [
      fn [x, y, z] -> [+x, +y, +z] end,
      fn [x, y, z] -> [+x, +y, -z] end,
      fn [x, y, z] -> [+x, -y, +z] end,
      fn [x, y, z] -> [+x, -y, -z] end,
      fn [x, y, z] -> [-x, +y, +z] end,
      fn [x, y, z] -> [-x, +y, -z] end,
      fn [x, y, z] -> [-x, -y, +z] end,
      fn [x, y, z] -> [-x, -y, -z] end
    ]
  end

  defp orientations() do
    [
      [fn [x, y, z] -> [x, y, z] end, fn [x, y, z] -> [x, y, z] end],
      [fn [x, y, z] -> [x, z, y] end, fn [x, z, y] -> [x, y, z] end],
      [fn [x, y, z] -> [y, x, z] end, fn [y, x, z] -> [x, y, z] end],
      [fn [x, y, z] -> [y, z, x] end, fn [y, z, x] -> [x, y, z] end],
      [fn [x, y, z] -> [z, x, y] end, fn [z, x, y] -> [x, y, z] end],
      [fn [x, y, z] -> [z, y, x] end, fn [z, y, x] -> [x, y, z] end]
    ]
  end

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    scanners = parse_input(input)

    adjacencies = find_common(scanners)

    first_scanner = hd(scanners)
    readings = MapSet.new(first_scanner.readings)

    all_adjacent_coords = collapse_common_coords(0, adjacencies, MapSet.new())

    all_coords =
      Enum.reduce(readings, all_adjacent_coords, fn coord, all -> MapSet.put(all, coord) end)

    MapSet.size(all_coords)
  end

  def solve(input, _part = "b") do
    input
    |> parse_input()
    |> find_common()
    |> find_scanner_positions()
  end

  # part 2
  defp find_scanner_positions(adjacencies) do
    rest_positions =
      find_adjacent_positions(0, adjacencies, MapSet.new())
      |> Enum.map(fn %{pos: pos} -> pos end)

    # include scanner 0 at 0,0,0
    positions = [
      [0, 0, 0] | rest_positions
    ]

    positions
    |> Enum.with_index()
    |> Enum.map(fn {coord, idx} ->
      distances(coord, Enum.take(positions, idx + 1))
      |> Enum.max()
    end)
    |> Enum.max()
  end

  defp find_adjacent_positions(id, adjacencies, seen) do
    new_seen = MapSet.put(seen, id)

    Map.get(adjacencies, id, [])
    |> Enum.filter(fn %{adjacent: adjacent} -> not MapSet.member?(seen, adjacent.id) end)
    |> Enum.flat_map(fn %{adjacent: adjacent, forward_offset: pos, forward_transform: t} ->
      [ox, oy, oz] = pos

      children =
        find_adjacent_positions(adjacent.id, adjacencies, new_seen)
        |> Enum.map(fn %{id: id, pos: child_pos} ->
          [cx, cy, cz] = t.(child_pos)

          %{
            id: id,
            pos: [cx + ox, cy + oy, cz + oz]
          }
        end)

      self = %{
        id: adjacent.id,
        pos: pos
      }

      [self | children]
    end)
  end

  defp distances(_, []) do
    []
  end

  defp distances([ax, ay, az], [[bx, by, bz] | rest]) do
    dist = abs(ax - bx) + abs(ay - by) + abs(az - bz)
    [dist | distances([ax, ay, az], rest)]
  end

  # part 1
  defp find_common(scanners) do
    scanners
    |> Enum.with_index()
    |> Enum.map(fn {scanner, idx} ->
      {scanner, find_common_overlap(scanner, Enum.drop(scanners, idx + 1))}
    end)
    |> Enum.reduce(%{}, fn {scanner, overlaps}, all ->
      new_adj = Map.update(all, scanner.id, overlaps, fn existing -> existing ++ overlaps end)

      overlaps
      |> Enum.reduce(new_adj, fn overlap, all ->
        new_entry = %{
          adjacent: scanner,
          forward_offset: overlap.invert_offset,
          forward_transform: overlap.invert_transform,
          invert_offset: overlap.forward_offset,
          invert_transform: overlap.forward_transform
        }

        Map.update(all, overlap.adjacent.id, [new_entry], fn existing ->
          [new_entry | existing]
        end)
      end)
    end)
  end

  defp find_common_overlap(_, []) do
    []
  end

  defp find_common_overlap(scannerA, [scannerB | rest]) do
    found = overlaps?(scannerA, scannerB)

    if is_nil(found) do
      find_common_overlap(scannerA, rest)
    else
      [found | find_common_overlap(scannerA, rest)]
    end
  end

  defp overlaps?(scannerA, scannerB) do
    coordsA = MapSet.new(scannerA.readings)

    transforms3()
    |> Enum.find_value(fn [t, invert] ->
      transformed_to_original =
        scannerB.readings
        |> Enum.map(fn b -> {t.(b), b} end)
        |> Enum.reduce(%{}, fn {transformed, original}, all ->
          Map.put(all, transformed, original)
        end)

      transformed_b_coords = Map.keys(transformed_to_original) |> Enum.sort()

      scannerA.readings
      |> Enum.find_value(fn [ax, ay, az] ->
        transformed_b_coords
        |> Enum.with_index()
        |> Enum.find_value(fn {[bx, by, bz], _idx} ->
          [ox, oy, oz] = [ax - bx, ay - by, az - bz]

          num_common =
            transformed_b_coords
            |> Enum.map(fn [bx, by, bz] -> [bx + ox, by + oy, bz + oz] end)
            |> Enum.count(fn coordB -> MapSet.member?(coordsA, coordB) end)

          if num_common >= 12 do
            [obx, oby, obz] = Map.get(transformed_to_original, [bx, by, bz])
            [tax, tay, taz] = invert.([ax, ay, az])
            invert_offset = [obx - tax, oby - tay, obz - taz]

            %{
              forward_offset: [ox, oy, oz],
              forward_transform: t,
              invert_transform: invert,
              invert_offset: invert_offset,
              adjacent: scannerB
            }
          end
        end)
      end)
    end)
  end

  defp collapse_common_coords(id, overlaps, seen) do
    new_seen = MapSet.put(seen, id)

    Map.get(overlaps, id, [])
    |> Enum.filter(fn adj -> not MapSet.member?(seen, adj.adjacent.id) end)
    |> Enum.flat_map(fn adj ->
      downstream = collapse_common_coords(adj.adjacent.id, overlaps, new_seen)

      adj.adjacent.readings
      |> Enum.reduce(downstream, fn coord, all -> MapSet.put(all, coord) end)
      |> Enum.map(fn c -> adj.forward_transform.(c) end)
      |> Enum.map(fn [x, y, z] ->
        [ox, oy, oz] = adj.forward_offset
        [x + ox, y + oy, z + oz]
      end)
    end)
    |> Enum.reduce(MapSet.new(), fn coord, all -> MapSet.put(all, coord) end)
  end

  # parsing
  defp parse_input([first_row | rest]) do
    [_, _, str_id, _] = String.split(first_row, " ")
    id = String.to_integer(str_id)

    {readings, remaining} = parse_readings(rest)

    scanner = %{
      id: id,
      readings: Enum.sort(readings)
    }

    if remaining == [] do
      [scanner]
    else
      [scanner | parse_input(remaining)]
    end
  end

  defp parse_readings([]) do
    {[], []}
  end

  defp parse_readings([row | rest]) do
    reading = parse_row(row)

    if is_nil(reading) do
      {[], rest}
    else
      {tl, remaining} = parse_readings(rest)
      {[reading | tl], remaining}
    end
  end

  defp parse_row(row) when row == "" do
    # nothing
    nil
  end

  defp parse_row(row) do
    row
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
