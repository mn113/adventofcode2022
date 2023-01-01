#! /usr/bin/env python3

import copy

ORE = 0
CLAY = 1
OBS = 2
GEODE = 3

blueprints = {}

with open("../inputs/input19.txt") as fp:
    for line in fp.readlines():
        words = line.split()
        blueprint = {}
        id_ = int(words[1].strip(":"))
        blueprint["id_"] = id_
        blueprint["costs"] = (
            int(words[6]), # oreBotOreCost
            int(words[12]), # clayBotOreCost
            (int(words[18]), int(words[21])), # obsidianBotOreCost, obsidianBotClayCost
            (int(words[27]), int(words[30])) # geodeBotOreCost, geodeBotObsidianCost
        )
        blueprints[id_] = blueprint

def initial_state():
    return {
        "time": 1,
        "resources": [0,0,0,0],
        "bots": [1,0,0,0],
        "history": [],
        "targetBotId": None # if in 0-3, represents the next intention of this state's path
    }

# See how many geodes can be produced in 24s
def execute_blueprint_variants(id_, max_time):
    print("Blueprint id:", id_)
    blueprint = blueprints[id_]
    costs = blueprint["costs"]

    open_paths = [initial_state()]
    max_geodes_obtained = 0
    best_path = None
    earliest_obsBot_buy = max_time
    earliest_geoBot_buy = max_time
    best_future_geos = [0]

    # put limits on bot numbers to reduce problem space
    max_ore_bots = max(costs[0], costs[1], costs[2][0], costs[3][0]) # to pay for 1 anyBot
    max_clay_bots = costs[2][1] # to pay for 1 obsidianBot
    if max_clay_bots > 10 and max_clay_bots % 2 == 0:
        max_clay_bots /= 2
    max_obsidian_bots = costs[3][1] # to pay for 1 geodeBot
    if max_obsidian_bots > 10 and max_obsidian_bots % 2 == 0:
        max_obsidian_bots /= 2
    bots_limits = [max_ore_bots, max_clay_bots, max_obsidian_bots]
    print(bots_limits)
    # bots_limits = [4,10,7]
    prev_time = -1

    # exhaustive BFS with pruning
    while len(open_paths) > 0:
        current, open_paths = open_paths[0], open_paths[1:]

        # explode state for local use
        time = current["time"]
        time_left = max_time - time
        if time > prev_time:
            print(time, len(open_paths))
            prev_time = time
            best_future_geos.append(0)

        ore, clay, obs, geo = current["resources"]
        oreBots, clayBots, obsBots, geoBots = current["bots"]
        history = current["history"]
        targetBotId = current["targetBotId"]

        # will be set if we decide to buy a bot in this round
        shopping_list = None

        can_afford_bots = [
            ore >= costs[ORE],
            ore >= costs[CLAY],
            ore >= costs[OBS][0] and clay >= costs[OBS][1],
            ore >= costs[GEODE][0] and obs >= costs[GEODE][1]
        ]

        # spend ore + obsidian on geodebot (by prev instruction)
        # TOP PRIORITY
        if targetBotId == GEODE and can_afford_bots[GEODE]:
            ore -= costs[GEODE][0]
            obs -= costs[GEODE][1]
            shopping_list = GEODE
            history.append(GEODE)
            if time < earliest_geoBot_buy:
                earliest_geoBot_buy = time

        # spend ore + clay on obsidianBot (by prev instruction)
        elif targetBotId == OBS and can_afford_bots[OBS]:
            ore -= costs[OBS][0]
            clay -= costs[OBS][1]
            shopping_list = OBS
            history.append(OBS)
            if time < earliest_obsBot_buy:
                earliest_obsBot_buy = time

        # spend ore on clayBot (by prev instruction)
        elif targetBotId == CLAY and can_afford_bots[CLAY]:
            ore -= costs[CLAY]
            shopping_list = CLAY
            history.append(CLAY)

        # spend ore on oreBot (by prev instruction)
        elif targetBotId == ORE and can_afford_bots[ORE]:
            ore -= costs[ORE]
            shopping_list = ORE
            history.append(ORE)

        # no spending possible in this turn (or: it's first turn)
        else:
            history.append(None)

        current["history"] = history

        # culling bad paths
        if geoBots == 0 and shopping_list != GEODE and time > earliest_geoBot_buy + 1:
            continue
        if obsBots == 0 and shopping_list != OBS and time > earliest_obsBot_buy + 2:
            continue

        # harvest resources
        geo += geoBots
        obs += obsBots
        clay += clayBots
        ore += oreBots
        current["resources"] = [ore, clay, obs, geo]

        if geo > max_geodes_obtained:
            max_geodes_obtained = geo
            best_path = current
            print("new max", max_geodes_obtained)

        # complete a pending bot build
        if shopping_list == GEODE:
            geoBots += 1
        elif shopping_list == OBS:
            obsBots += 1
        elif shopping_list == CLAY:
            clayBots += 1
        elif shopping_list == ORE:
            oreBots += 1
        current["bots"] = [oreBots, clayBots, obsBots, geoBots]

        # culling bad paths
        future_geodes = geo + ((geoBots + time_left - 1) * time_left)
        if future_geodes < max_geodes_obtained:
            continue

        # prepare plans for next bot:
        buy_geoBot_next = obsBots > 0 and time_left >= 1
        buy_obsBot_next = clayBots > 0 and time_left >= 4 and obsBots <= bots_limits[OBS] and obs < costs[GEODE][1]
        buy_clayBot_next = time_left >= 8 and clayBots <= bots_limits[CLAY] and clay < costs[OBS][1]
        buy_oreBot_next = time_left >= 12 and oreBots <= bots_limits[ORE]

        # handle time
        if time + 1 > max_time:
            continue
        current["time"] = time + 1

        # split path multiple ways
        if current["history"] == [None] or shopping_list != None:
            # target bot was bought: plan to buy next
            if buy_geoBot_next:
                open_paths.append({**copy.deepcopy(current), "targetBotId": GEODE})

            if buy_obsBot_next:
                open_paths.append({**copy.deepcopy(current), "targetBotId": OBS})

            if buy_clayBot_next:
                open_paths.append({**copy.deepcopy(current), "targetBotId": CLAY})

            if buy_oreBot_next:
                open_paths.append({**copy.deepcopy(current), "targetBotId": ORE})
        else:
            # nothing was bought, keep saving up
            open_paths.append(current)

    print("best", best_path)
    return max_geodes_obtained

# Part 1: find total of all blueprints qualities (id * geodes) in 24 seconds
max_time = 24
outcomes = [(id_, execute_blueprint_variants(id_, max_time)) for id_ in blueprints.keys()]
products = [id_ * g for (id_, g) in outcomes]
print(outcomes) # [(1, 1), (3, 3), (5, 2), (7, 3), (8, 13), (10, 10), (15, 2), (19, 2), (20, 12), (21, 3), (2, 0), (4, 1), (6, 1), (9, 1), (11, 2), (12, 0), (13, 0), (14, 1), (16, 0), (17, 1), (18, 0), (22, 0), (23, 0), (24, 2), (25, 0), (26, 1), (27, 0), (28, 1), (29, 0), (30, 0)]
print("P1:", sum(products)) # 790

# Part 2: use only first 3 blueprints, increase time to 32, ignore ids. Product of max geodes.
max_time = 32
g1 = execute_blueprint_variants(1, max_time) # BP1: 21 with bots_limits = [4,10,7]
g2 = execute_blueprint_variants(2, max_time) # BP2: 10 with bots_limits = [3,10,10]
g3 = execute_blueprint_variants(3, max_time) # BP3: 35 with bots_limits = [3,8,9]
print([g1,g2,g3])
print("P2:", g1 * g2 * g3) # 7350
