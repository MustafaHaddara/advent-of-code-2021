test_input = [
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

def parse_rules(rules):
    res = {}
    for r in rules:
        a,b = r.split(" -> ")
        res[a] = b
    return res

def insert(chars, rules):
    res = ''
    prev = ''
    for i in range(0, len(chars)):
        current = chars[i]
        pair = prev+current

        if rules.get(pair):
            res+=rules.get(pair) + current
        else:
            res+=current

        prev = current
    return res

def expand_rules(rules, iterations):
    expanded = {}
    for k in rules:
        r = k
        for i in range(iterations):
            r = insert(r, rules)
        expanded[k] = r
    return expanded

def freqs(expanded):
    freqs = {}
    for k,v in expanded.items():
        freqs[k] = str_freq(v)
    return freqs

def str_freq(s):
    freqs = {}
    for c in s:
        current = freqs.get(c, 0)
        freqs[c] = current+1
    return freqs

def get_pairs(template):
    pairs = []
    for i in range(1, len(template)):
        prev = template[i-1]
        current = template[i]
        pairs.append(prev+current)
    return pairs

def merge(m1, m2):
    for (k,v2) in m2.items():
        v1 = m1.get(k, 0)
        m1[k] = v1+v2

def solve(input):
    template = input[0]
    rules = parse_rules(input[2:])

    expanded = expand_rules(rules, 20)
    frequencies = freqs(expanded)

    pairs = get_pairs(template)
    expanded_to_20 = ''
    for p in pairs:
        if expanded_to_20 == '':
            expanded_to_20 = expanded[p]
        else:
            expanded_to_20 += expanded[p][1:] # drop the first char
    
    total_freqs = { template[0]: 1 } # make sure we count the very first char
    for p in get_pairs(expanded_to_20):
        merge(total_freqs, frequencies[p])
        merge(total_freqs, { p[0]: -1 }) # drop the first char

    print(total_freqs)
    min_amount = min(total_freqs.values())
    max_amount = max(total_freqs.values())
    print(max_amount - min_amount)

def test():
    solve(test_input)

def main():
    with open('inputs/day14.txt', 'r') as f:
        solve([l.strip() for l in f.readlines()])

main()
