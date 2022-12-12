#! /usr/bin/env python3

# Load maze file into nested array:
with open('../inputs/input12.txt') as fp:
    grid = [[char for char in line_str.strip()] for line_str in fp.readlines()]
ydim = len(grid) - 1
xdim = len(grid[0]) - 1

START_CHAR, GOAL_CHAR = "S", "E"
LOW_CHAR, HIGH_CHAR = "a", "z"
start_xy, goal_xy = None, None

# need to locate START and GOAL symbols
for y in range(ydim):
    for x in range(xdim):
        if grid[y][x] == START_CHAR:
            start_xy = (x,y)
            # now start_xy is known, replace its val with 'a':
            grid[y][x] = LOW_CHAR
        elif grid[y][x] == GOAL_CHAR:
            goal_xy = (x,y)
            # now goal_xy is known, replace its val with 'z':
            grid[y][x] = HIGH_CHAR
        if start_xy and goal_xy:
            break

def grid_val(coords):
    (x,y) = coords
    return grid[y][x]

def manhattan_dist(a,b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

# Return valid points of [down, left, up, right] from given point (x,y)
def neighbours(point):
    (x,y) = point
    up    = (x, max(y-1, 0))
    down  = (x, min(y+1, ydim))
    left  = (max(x-1, 0), y)
    right = (min(x+1, xdim), y)
    # nb must not be x,y
    return [nb for nb in [down, left, up, right] if not (nb[0] == x and nb[1] == y)]

# Main algo: Dijkstra / BFS
# Finds lowest cost path from start to goal. Visits all points in grid, storing and updating cost to reach each one.
def dijkstra(start, goal):
    steps_to = {start: 0} # measures cumulative cost from start to each node; keys function as "seen" list
    to_visit = [start]          # list-as-queue
    came_from = {start: None}   # traces the optimal path taken

    while len(to_visit) > 0:
        # Shift first
        currentNode, to_visit = to_visit[0], to_visit[1:]
        currentVal = grid_val(currentNode)

        if currentNode == goal:
            print('GOAL!', len(to_visit), "to see")
            # Keep searching, to guarantee shortest:
            continue

        neighbs = neighbours(currentNode)

        for nextNode in neighbs:
            nextVal = grid_val(nextNode)
            # reject too-big jumps in letter value:
            ord_jump = ord(nextVal) - ord(currentVal)
            if ord_jump > 1:
                continue

            # nextNode unseen:
            if nextNode not in steps_to.keys():
                to_visit.append(nextNode)
                # Next node will cost 1 more than this node did:
                steps_to[nextNode] = steps_to[currentNode] + 1
                came_from[nextNode] = currentNode

            # nextNode seen before:
            else:
                if steps_to[nextNode] > steps_to[currentNode] + 1:
                    # Via currentNode, we have found a new, shorter path to nextNode:
                    steps_to[nextNode] = steps_to[currentNode] + 1
                    came_from[nextNode] = currentNode
                    to_visit.append(nextNode)

                elif steps_to[currentNode] > steps_to[nextNode] + 1:
                    # Re-validate this backwards step can be taken:
                    if ord_jump < -1:
                        continue
                    # Via nextNode, we have found a new, shorter path to currentNode:
                    steps_to[currentNode] = steps_to[nextNode] + 1
                    came_from[currentNode] = nextNode
                    to_visit.append(currentNode)

    if goal in came_from.keys():
        print("steps to goal", steps_to[goal])
        traceback(came_from)

route = []

# Follow path back from goal to start
def traceback(came_from):
    global route
    loc = goal_xy
    route = [loc]
    while loc != start_xy:
        loc = came_from[loc]
        route.append(loc)

# part 1 - find fewest steps from start to goal
print(start_xy, "to", goal_xy)
dijkstra(start_xy, goal_xy) # P1: 370

# part 2 - find fewest steps from goal to nearest 'a'
print("steps to", LOW_CHAR, "".join([grid_val(p) for p in route]).find(LOW_CHAR)) # P2: 363
