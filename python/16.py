#! /usr/bin/env python3

import itertools

# Dict of room keys to lists of child room keys
#'AA': ['BB','CC']
rooms = {
}

# Dict of room keys to tuples (flow, closed|open)
#'AA': (43, 0)
valves = {
}

with open('../inputs/input16.txt') as fp:
    for line in fp.readlines():
        words = line.split()
        valve = words[1]
        rate = int(words[4].strip(";").split("=")[1])
        conns = [w.strip(",") for w in words[9:]]
        rooms[valve] = conns
        if rate > 0:
            valves[valve] = (rate, 0)

# Sum the flows in all the valves which are currently open
def count_flow():
    return sum([v[0] * v[1] for v in valves.values()])

def open_valve(loc):
    valves[loc] = (valves[loc][0], 1)

def close_valve(loc):
    valves[loc] = (valves[loc][0], 0)

def reset_valves():
    for loc in valves.keys():
        close_valve(loc)

# Dict of location keys to path lists
# "AADD": ["BB","CC","DD"]
paths_memo = {}

# Find the shortest path between loc and dest
def find_path(loc, dest):
    # memoised:
    if loc + dest in paths_memo:
        return paths_memo[loc + dest]

    # print("find path", loc, dest)
    open_routes = [[loc]]
    dead_routes = []
    good_routes = []
    while 1:
        if len(open_routes) == 0:
            break
        for route in open_routes:
            children = rooms[route[-1]]
            for child in children:
                route2 = route[:]
                route2.append(child)
                if child == dest:
                    # bingo
                    good_routes.append(route2)
                elif len(route2) > len(set(route2)):
                    # route has dupes
                    dead_routes.append(route2)
                else:
                    # route stays open
                    open_routes.append(route2)
            open_routes = [r for r in open_routes if r != route]

    chosen_route = sorted(good_routes, key=len)[0]
    # memoise:
    paths_memo[loc + dest] = chosen_route
    return chosen_route

# How many walking steps are needed to traverse a valve room sequence
def evaluate_sequence_length(seq):
    return sum([len(find_path(a,b)) for a,b in zip(seq, seq[1:])])

# Roughly how much pressure will a valve sequence return
def evaluate_sequence_value(seq):
    return sum([t * valves[loc][0] for t,loc in zip(list(range(25,0,-3)), seq)])

# See how much flow can be achieved in 30 minutes
def solve_max_flow_sum(valve_perms, max_time=30):
    max_flow_sum = 0
    best_perm = None
    pc = 0
    for perm in valve_perms:
        pc += 1
        # preliminary check
        perm_estimated_value = evaluate_sequence_value(perm)
        if perm_estimated_value < 750: # underperfoming
            continue

        reset_valves()
        loc = "AA"
        time = 0
        flow_sum = 0
        i = 0
        while time < max_time:
            nextloc = perm[i]
            if loc != nextloc:
                steps = find_path(loc, nextloc)
                for s in steps[1:]:
                    loc = s
                    flow_sum += count_flow()
                    time += 1
                    if time >= max_time:
                        break
            else:
                flow_sum += count_flow()
                if valves[loc][1] == 0:
                    open_valve(loc)
                time += 1
                if time >= max_time:
                    break
                # to next loc
                if i + 1 < len(perm):
                    i += 1

        if flow_sum > max_flow_sum:
            max_flow_sum = flow_sum
            best_perm = perm
            print("new max", max_flow_sum, perm, len(valve_perms) - pc, "perms to go")

    print("final max", max_flow_sum, best_perm)
    return [best_perm, max_flow_sum]

# Part 1: find maximum aggregate valve flow achievable in 30 minutes
# Permute the valves to try all orders
high_valves_keys = [v for v in valves.keys() if valves[v][0] > 9] # cut out worthless valves (the valve worth 10 is required in p1 solution)
high_valve_perms = list(itertools.permutations(high_valves_keys)) # RAM cannot process permutations of 15 elements
bad_starts = ["XK", "XS", "NM", "NC", "MW", "YP", "ZG", "EI"]
selected_valve_perms = [vp for vp in high_valve_perms if vp[0] not in bad_starts]
print(len(selected_valve_perms), "perms")
[p1_perm, p1_sum] = solve_max_flow_sum(selected_valve_perms, 30) # ('NU', 'WK', 'NC', 'ZG', 'XK', 'YH', 'NM', 'YP', 'XS', 'MW')
print("P1:", p1_sum) # 1754

# Part 2: human's 26-second run and elephant's 26-second run go in parallel:
# divided valves according to graphviz overview:
group_a = ["RA","XK","YH","XS","NM","YP","EI","MW"]
group_b = ["NC","ZG","NU","WK","EA","CX","QC"]
group_a_perms = list(itertools.permutations(group_a))
group_b_perms = list(itertools.permutations(group_b))
print(len(group_a_perms), "A perms")
print(len(group_b_perms), "B perms")

[p2a_perm, p2a_sum] = solve_max_flow_sum(group_a_perms, 26) # 1301: ('XK', 'YH', 'NM', 'YP', 'XS', 'RA', 'EI', 'MW')
[p2b_perm, p2b_sum] = solve_max_flow_sum(group_b_perms, 26) # 1173: ('NU', 'WK', 'NC', 'ZG', 'EA', 'CX', 'QC')
print("P2:", p2a_sum + p2b_sum) # 2474
