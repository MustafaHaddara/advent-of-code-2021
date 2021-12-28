class Range:
    def __init__(self, start, end):
        self.start = start
        self.end = end
    def __eq__(self, other) -> bool:
        if type(other) != Range:
            return False
        return self.start == other.start and self.end == other.end
    def __repr__(self) -> str:
        return f"{self.start}..{self.end}"

class Box:
    def __init__(self, x: Range, y: Range, z: Range):
        self.x = x
        self.y = y
        self.z = z
    def __eq__(self, other: object) -> bool:
        if type(other) != Box:
            return False
        return self.x == other.x and self.y == other.y and self.z == other.z
    def __repr__(self) -> str:
        return f"x: {self.x} | y: {self.y} | z: {self.z}"
    
    def size(self):
        return (1 + self.x.end - self.x.start) * (1 + self.y.end - self.y.start) * (1 + self.z.end - self.z.start)

class Operation:
    def __init__(self, ins, box: Box):
        self.ins = ins
        self.box = box

class AppendableNode:
    def __init__(self, val):
        self.val = val
        self.next = None

    def __eq__(self, other: object) -> bool:
        if type(other) != AppendableNode:
            return False
        return self.val == other.val
    
    def __hash__(self) -> int:
        return id(self)

class AppendableList:
    def __init__(self):
        self.first: AppendableNode = None
        self.last: AppendableNode = None
    
    def add_item(self, val):
        n = AppendableNode(val)
        if self.first is None:
            self.first = n
            self.last = n
        else:
            self.last.next = n
            self.last = n

    def add_list(self, other):
        if self.first is None:
            self.first = other.first
            self.last = other.last
        elif not other.is_empty():
            self.last.next = other.first
            self.last = other.last

    def pop(self):
        if self.first is None:
            return None

        result = self.first

        self.first = result.next
        if self.first is None:
            self.last = None

        return result.val

    def is_empty(self):
        return self.first is None

    def __iter__(self):
        return AppendableListIterator(self.first)

class AppendableListIterator:
    def __init__(self, c):
        self.c = c

    def __next__(self):
        res = self.c
        if res is not None:
            self.c = res.next
            return res.val

        raise StopIteration

def range_overlap(a: Range, b: Range):
    return (b.start <= a.start <= b.end) or (a.start <= b.start <= a.end)

def box_overlap(a: Box, b: Box):
    return range_overlap(a.x, b.x) and range_overlap(a.y, b.y) and range_overlap(a.z, b.z)

def range_intersect(a: Range, b: Range):
    return Range(max(a.start, b.start), min(a.end, b.end))

# must overlap
def box_intersect(a: Box, b: Box):
    x =  range_intersect(a.x, b.x)
    y =  range_intersect(a.y, b.y)
    z =  range_intersect(a.z, b.z)

    return Box(x, y, z)

# must overlap
def box_subtract(a: Box, b: Box):
    intersect = box_intersect(a, b)
    x_ranges = range_split(a.x, intersect.x)
    y_ranges = range_split(a.y, intersect.y)
    z_ranges = range_split(a.z, intersect.z)

    result = AppendableList()
    for xr in x_ranges:
        for yr in y_ranges:
            for zr in z_ranges:
                b = Box(xr,yr,zr)
                if b != intersect:
                    result.add_item(b)
    return result

def range_split(r1: Range, r2: Range):
    # r1 within r2
    if r2.start <= r1.start and r1.end <= r2.end:
        return [r2]

    # r1 before r2
    elif r1.start < r2.start and r1.end < r2.end:
        return [
            Range(r1.start, r1.end - 1),
            r2
        ]

    # r1 after r2
    elif r2.start < r1.start and r2.end < r1.end:
        return [
            r2,
            Range(r1.start + 1, r1.end)
        ]

    # r2 within r1
    elif r1.start < r2.start and r2.end < r1.end:
        return [
            Range(r1.start, r2.start-1),
            r2,
            Range(r2.end+1, r1.end)
        ]
    elif r1.start <= r2.start and r2.end == r1.end:
        return [
            Range(r1.start, r2.start-1),
            r2,
        ]
    elif r1.start == r2.start and r2.end <= r1.end:
        return [
            r2,
            Range(r2.end+1, r1.end)
        ]
    
    else:
        print(r1, r2)
        raise Exception('oh no')

def box_add(a: Box, b: Box):
    intersect = box_intersect(a,b)

    used = AppendableList()
    used.add_item(a)

    remaining = box_subtract(b, intersect)

    return (used, remaining)

def build_box(x1,x2, y1,y2, z1,z2):
    return Box(Range(x1,x2), Range(y1,y2), Range(z1,z2))

def sizes(boxes: Box):
    return sum(b.size() for b in boxes)

def parse_chunk(c):
    [s, e] = c[2:].split("..")
    return Range(int(s), int(e))

def parse(lines):
    ops = []
    for line in lines:
        [ins, spec] = line.split(" ")
        [xchunk, ychunk, zchunk] = spec.split(",")
        x = parse_chunk(xchunk)
        y = parse_chunk(ychunk)
        z = parse_chunk(zchunk)

        ops.append(Operation(ins, Box(x, y, z)))
    return ops

def inner_turn_box_on(to_add: AppendableList, boxes: AppendableList):
    unprocessed = AppendableList()
    while not to_add.is_empty():
        box = to_add.pop()
        new_res = AppendableList()
        while not boxes.is_empty():
            existing = boxes.pop()
            if box_overlap(existing, box):
                (added, remaining) = box_add(existing, box)

                new_res.add_list(added)
                new_res.add_list(boxes)

                to_add.add_list(remaining)
                to_add.add_list(unprocessed)

                return new_res, to_add
            else:
                # do nothing
                new_res.add_item(existing)
        unprocessed.add_item(box)
        boxes = new_res

    new_res.add_list(unprocessed)
    return new_res, AppendableList()

def turn_box_on(to_add: AppendableList, boxes: AppendableList):
    new_res, unprocessed = inner_turn_box_on(to_add, boxes)
    while not unprocessed.is_empty():
        new_res, unprocessed = inner_turn_box_on(unprocessed, new_res)
    return new_res

def length(l):
    r = 0
    for i in l:
        r+=1
    return r

if __name__ == '__main__':
    test_input = [
        "on x=-5..47,y=-31..22,z=-19..33",
        "on x=-44..5,y=-27..21,z=-14..35",
        "on x=-49..-1,y=-11..42,z=-10..38",
        "on x=-20..34,y=-40..6,z=-44..1",
        "off x=26..39,y=40..50,z=-2..11",
        "on x=-41..5,y=-41..6,z=-36..8",
        "off x=-43..-33,y=-45..-28,z=7..25",
        "on x=-33..15,y=-32..19,z=-34..11",
        "off x=35..47,y=-46..-34,z=-11..5",
        "on x=-14..36,y=-6..44,z=-16..29",
        "on x=-57795..-6158,y=29564..72030,z=20435..90618",
        "on x=36731..105352,y=-21140..28532,z=16094..90401",
        "on x=30999..107136,y=-53464..15513,z=8553..71215",
        "on x=13528..83982,y=-99403..-27377,z=-24141..23996",
        "on x=-72682..-12347,y=18159..111354,z=7391..80950",
        "on x=-1060..80757,y=-65301..-20884,z=-103788..-16709",
        "on x=-83015..-9461,y=-72160..-8347,z=-81239..-26856",
        "on x=-52752..22273,y=-49450..9096,z=54442..119054",
        "on x=-29982..40483,y=-108474..-28371,z=-24328..38471",
        "on x=-4958..62750,y=40422..118853,z=-7672..65583",
        "on x=55694..108686,y=-43367..46958,z=-26781..48729",
        "on x=-98497..-18186,y=-63569..3412,z=1232..88485",
        "on x=-726..56291,y=-62629..13224,z=18033..85226",
        "on x=-110886..-34664,y=-81338..-8658,z=8914..63723",
        "on x=-55829..24974,y=-16897..54165,z=-121762..-28058",
        "on x=-65152..-11147,y=22489..91432,z=-58782..1780",
        "on x=-120100..-32970,y=-46592..27473,z=-11695..61039",
        "on x=-18631..37533,y=-124565..-50804,z=-35667..28308",
        "on x=-57817..18248,y=49321..117703,z=5745..55881",
        "on x=14781..98692,y=-1341..70827,z=15753..70151",
        "on x=-34419..55919,y=-19626..40991,z=39015..114138",
        "on x=-60785..11593,y=-56135..2999,z=-95368..-26915",
        "on x=-32178..58085,y=17647..101866,z=-91405..-8878",
        "on x=-53655..12091,y=50097..105568,z=-75335..-4862",
        "on x=-111166..-40997,y=-71714..2688,z=5609..50954",
        "on x=-16602..70118,y=-98693..-44401,z=5197..76897",
        "on x=16383..101554,y=4615..83635,z=-44907..18747",
        "off x=-95822..-15171,y=-19987..48940,z=10804..104439",
        "on x=-89813..-14614,y=16069..88491,z=-3297..45228",
        "on x=41075..99376,y=-20427..49978,z=-52012..13762",
        "on x=-21330..50085,y=-17944..62733,z=-112280..-30197",
        "on x=-16478..35915,y=36008..118594,z=-7885..47086",
        "off x=-98156..-27851,y=-49952..43171,z=-99005..-8456",
        "off x=2032..69770,y=-71013..4824,z=7471..94418",
        "on x=43670..120875,y=-42068..12382,z=-24787..38892",
        "off x=37514..111226,y=-45862..25743,z=-16714..54663",
        "off x=25699..97951,y=-30668..59918,z=-15349..69697",
        "off x=-44271..17935,y=-9516..60759,z=49131..112598",
        "on x=-61695..-5813,y=40978..94975,z=8655..80240",
        "off x=-101086..-9439,y=-7088..67543,z=33935..83858",
        "off x=18020..114017,y=-48931..32606,z=21474..89843",
        "off x=-77139..10506,y=-89994..-18797,z=-80..59318",
        "off x=8476..79288,y=-75520..11602,z=-96624..-24783",
        "on x=-47488..-1262,y=24338..100707,z=16292..72967",
        "off x=-84341..13987,y=2429..92914,z=-90671..-1318",
        "off x=-37810..49457,y=-71013..-7894,z=-105357..-13188",
        "off x=-27365..46395,y=31009..98017,z=15428..76570",
        "off x=-70369..-16548,y=22648..78696,z=-1892..86821",
        "on x=-53470..21291,y=-120233..-33476,z=-44150..38147",
        "off x=-93533..-4276,y=-16170..68771,z=-104985..-24507",
    ]

    with open('inputs/day22.txt') as f:
        real_input = f.readlines()
    ops = parse(real_input)

    res = AppendableList()
    for op in ops:
        if op.ins == "on":
            box_q = AppendableList()
            box_q.add_item(op.box)
            new_res = turn_box_on(box_q, res)
        elif op.ins == "off":
            new_res = AppendableList()
            box = op.box
            for existing in res:
                if box_overlap(existing, box):
                    new_res.add_list(box_subtract(existing, box))
                else:
                    # do nothing
                    new_res.add_item(existing)
        res = new_res

    print(length(res))
    print(sizes(res))