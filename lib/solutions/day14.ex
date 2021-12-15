defmodule Day14 do
  @test_input [
    "NNCB",
    "",
    "CH -> B",
    "HH -> N",
    "CB -> H",
    "NH -> C",
    "HB -> C",
    "HC -> B",
    "HN -> C",
    "NN -> C",
    "BH -> H",
    "NC -> B",
    "NB -> B",
    "BN -> B",
    "BB -> N",
    "BC -> B",
    "CC -> N",
    "CN -> C"
  ]

  def test(part) do
    solve(@test_input, part)
  end

  def solve(input, _part = "a") do
    [template, _ | rest] = input
    rules = make_map(rest)

    freqs =
      template
      |> String.codepoints()
      |> apply_rules(rules, 10)
      |> Enum.frequencies()

    min = Enum.min(Map.values(freqs))
    max = Enum.max(Map.values(freqs))
    max - min
  end

  def solve(input, _part = "b") do
    [template, _ | rest] = input
    rules = make_map(rest)

    expanded_20 = expand_rules(rules, 20)

    freqs_20 =
      expanded_20
      |> Enum.map(fn {k, v} -> {k, Enum.frequencies(v)} end)
      |> Enum.reduce(%{}, fn {k, v}, all -> Map.put(all, k, v) end)

    template_list = String.codepoints(template)
    first_char = hd(template_list)
    chunks_1 = apply_rules_b(template_list, expanded_20)
    chunks_2 = get_freqs(chunks_1, freqs_20)

    freqs =
      Enum.reduce(chunks_2, %{first_char => 1}, fn freq, all ->
        Map.merge(all, freq, fn _, v1, v2 -> v1 + v2 end)
      end)

    min = Enum.min(Map.values(freqs))
    max = Enum.max(Map.values(freqs))
    max - min
  end

  defp get_pairs(l) do
    l
    |> Enum.zip(tl(l))
    |> Enum.map(fn {a, b} -> Enum.join([a, b]) end)
  end

  defp make_map(rules) do
    Enum.reduce(
      rules,
      %{},
      fn rule, all ->
        [a, b] = String.split(rule, " -> ")
        Map.put(all, a, b)
      end
    )
  end

  # part 2
  defp expand_rules(rules, itrs) do
    rules
    |> Enum.map(fn {k, _v} -> {k, apply_rules(String.codepoints(k), rules, itrs)} end)
    |> Enum.reduce(%{}, fn {k, v}, all -> Map.put(all, k, v) end)
  end

  defp apply_rules_b(starting, lookup) do
    [first | rest_expanded] =
      starting
      |> get_pairs()
      |> Enum.map(fn pair -> Map.get(lookup, pair) end)

    # drop first char for everything except first entry
    rest_trimmed = Enum.flat_map(rest_expanded, fn s -> tl(s) end)
    first ++ rest_trimmed
  end

  defp get_freqs([], _) do
    []
  end

  defp get_freqs(expanded_to_20, lookup) do
    expanded_to_20
    |> Enum.zip(tl(expanded_to_20))
    |> Enum.map(fn {a, b} -> {a, b, Enum.join([a, b])} end)
    |> Enum.map(fn {a, b, pair} -> {a, b, Map.get(lookup, pair)} end)
    # decrement first char by 1
    |> Enum.map(fn {a, b, f} -> {a, b, Map.update(f, a, 0, fn e -> e - 1 end)} end)
    |> Enum.map(fn {_, _, f} -> f end)
  end

  # part 1
  defp apply_rules(starting, _rules, 0) do
    starting
  end

  defp apply_rules(starting, rules, steps) do
    next_phase = insert(starting, "", [], rules)

    apply_rules(next_phase, rules, steps - 1)
  end

  defp insert([], _, result, _) do
    Enum.reverse(result)
  end

  defp insert([current_char | rest], prev_char, result, rules) do
    key = prev_char <> current_char
    to_insert = Map.get(rules, key)

    if is_nil(to_insert) do
      insert(rest, current_char, [current_char | result], rules)
    else
      insert(rest, current_char, [current_char | [to_insert | result]], rules)
    end
  end
end
