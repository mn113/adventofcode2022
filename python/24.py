#! /usr/bin/env python3

grid = []
# breakdown of the grid into separate components
westerlies = []
easterlies = []
northerlies = []
southerlies = []

with open('../inputs/input24.txt') as fp:
    for line in fp.readlines()[1:-1]:
        grid.append(line.strip()[1:-1])

for row in grid:
    westerlies.append(row.replace('>', '.').replace('^', '.').replace('v', '.'))
    easterlies.append(row.replace('<', '.').replace('^', '.').replace('v', '.'))

for x in range(len(grid[0])):
    col = ''.join([row[x] for row in grid])
    northerlies.append(col.replace('>', '.').replace('<', '.').replace('v', '.'))
    southerlies.append(col.replace('>', '.').replace('<', '.').replace('^', '.'))

ydim = len(grid)
xdim = len(grid[0])
print('grid', ydim, 'x', xdim)
grid_period = 600 # lcm(ydim, xdim)

elf_start = {'y': -1, 'x': 0}
elf_goal = {'y': ydim, 'x': xdim - 1}
# actual start/goal are 1 step less/more in y (but shouldn't be used due to coords)
adjacent_to_start = {'y': 0, 'x': 0}
adjacent_to_goal = {'y': ydim - 1, 'x': xdim - 1}

rows_at_times_memo = {}

def get_row_at_time(y, t):
    t = t % xdim
    if (y,t) in rows_at_times_memo:
        return rows_at_times_memo[(y,t)]
    row_easters = easterlies[y][-t:] + easterlies[y][:-t]
    row_westers = westerlies[y][t:] + westerlies[y][:t]
    row_at_time = ''.join(['.' if e == '.' and w == '.' else 'X' for (e,w) in zip(row_easters, row_westers)])
    rows_at_times_memo[(y,t)] = row_at_time
    return row_at_time

cols_at_times_memo = {}

def get_col_at_time(x, t):
    t = t % ydim
    if (x,t) in cols_at_times_memo:
        return cols_at_times_memo[(x,t)]
    col_northers = northerlies[x][t:] + northerlies[x][:t]
    col_southers = southerlies[x][-t:] + southerlies[x][:-t]
    col_at_time = ''.join(['.' if n == '.' and s == '.' else '#' for (n,s) in zip(col_northers, col_southers)])
    cols_at_times_memo[(x,t)] = col_at_time
    return col_at_time

locations_valid_at_times_memo = {}

def location_valid_at_time(loc, t):
    if loc == elf_start or loc == elf_goal: # off-grid special cases that are always valid
        return True
    t = t % grid_period
    loctimetup = (loc['x'], loc['y'], t)
    if loctimetup in locations_valid_at_times_memo:
        return locations_valid_at_times_memo[loctimetup]
    row_valid = get_row_at_time(loc['y'], t)[loc['x']] == '.'
    col_valid = get_col_at_time(loc['x'], t)[loc['y']] == '.'
    result = row_valid and col_valid
    locations_valid_at_times_memo[loctimetup] = result
    return result

# Get the 4 neighbouring points within the grid
def neighbs(loc):
    candidates = [
        {'y': loc['y'] + 1, 'x': loc['x']},
        {'y': loc['y'] - 1, 'x': loc['x']},
        {'y': loc['y'], 'x': loc['x'] + 1},
        {'y': loc['y'], 'x': loc['x'] - 1}
    ]
    return [c for c in candidates if c['y'] >= 0 and c['y'] < ydim and c['x'] >= 0 and c['x'] < xdim]

# Find the quickest path (fewest steps) between start and goal
def find_quickest_path(start, goal, start_time=0):
    fastest_time = 1000 # arbitrary upper limit to optimize the search
    # highest_xy = 0
    open_routes = [(start, start_time)]
    seen = set([])
    while len(open_routes) > 0:
        loc, t = open_routes.pop(0)

        # test if at goal
        if loc == goal:
            print('reached goal', loc, 'at t =', t)
            if t < fastest_time:
                fastest_time = t
                print('new fastest time', t)
            continue

        # abandon if too slow
        if t >= fastest_time:
            continue

        # reject if in a cycle (related to period of the row & col cycles)
        if (loc['x'], loc['y'], t % grid_period) in seen:
            continue
        else:
            seen.add((loc['x'], loc['y'], t % grid_period))

        # test the 5 options (4 neighbours + 1 wait in place) at t+1
        t += 1
        locs = neighbs(loc) + [loc]
        options = [nb for nb in locs if location_valid_at_time(nb, t)]

        # enqueue valid options, if any
        open_routes += [(o,t) for o in options]

    print()
    return fastest_time

# Part 1
leg1_end_time = find_quickest_path(elf_start, adjacent_to_goal) + 1
print("P1:", leg1_end_time) # 301
# Part 2
leg2_end_time = find_quickest_path(elf_goal, adjacent_to_start, leg1_end_time) + 1
print('leg2:', leg2_end_time)
leg3_end_time = find_quickest_path(elf_start, adjacent_to_goal, leg2_end_time) + 1
print("P2:", leg3_end_time) # 859
