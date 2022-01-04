from queue import PriorityQueue

test_input = [
    "1163751742",
    "1381373672",
    "2136511328",
    "3694931569",
    "7463417111",
    "1319128137",
    "1359912421",
    "3125421639",
    "1293138521",
    "2311944581"
]

def int_rows(rows):
    return [[int(r) for r in row] for row in rows]

def clone_rows(rows, times):
    parsed = int_rows(rows)
    res_1 = []
    # multiply vertically
    for i in range(times):
        for row in parsed:
            new_row = []
            for c in row:
                next_c = c+i
                new_row.append(next_c if next_c <= 9 else next_c-9)
            res_1.append(new_row)

    res = []
    # multiply horizontally
    for row in res_1:
        new_row = []
        for i in range(times):
            for c in row:
                next_c = c+i
                new_row.append(next_c if next_c <= 9 else next_c-9)
        res.append(new_row)

    return res


def build_map(rows):
    adjacents = {}
    size = len(rows)
    for y,row in enumerate(rows):
        for x,c in enumerate(row):
            for a in adjacent(x,y, size):
                if a not in adjacents:
                    adjacents[a] = []
                adjacents[a].append((c, x, y))
    return adjacents

def adjacent(x, y, size):
    a = [ (x-1, y), (x+1, y), (x, y-1), (x, y+1) ]
    return [
        (x,y) for (x,y) in a if x>=0 and y>=0 and x<size and y<size
    ]

def shortest_path(adjacent, current, ending):
    distances = {}
    current_cost = 0
    remaining = PriorityQueue()
    while current != ending:
        distances[current] = current_cost

        # print(current, current_cost)
        for (c, x,y) in adjacent[current]:
            if (x,y) not in distances:
                remaining.put((c+current_cost, x,y))

        (c, x,y) = remaining.get()
        while (x,y) in distances:
            (c, x,y) = remaining.get()

        current_cost = c
        current = (x,y)

    return current_cost

def solve(rows):
    parsed = clone_rows(rows, 5)
    # for r in parsed:
    #     print("".join(str(i) for i in r))
    adjacent = build_map(parsed)
    size = len(parsed)

    return shortest_path(adjacent, (0,0), (size-1, size-1))

def test():
    print(solve(test_input))

def main():
    with open('inputs/day15.txt', 'r') as f:
        print(solve([l.strip() for l in f.readlines()]))

main()