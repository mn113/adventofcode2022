const p = console.log;

const fs = require('fs');
const JETS = fs.readFileSync('../inputs/input17.txt', 'utf-8').split("");
const LJET = '<';
const RJET = '>';
let j = 0; // jet index, will be incremented indefinitely

const SPACE = "."
const ROCK = "█"
const FALLING = "@"

const CAVE_WIDTH = 7;

/**
 * State object of a Shape
 */
function Shape(pattern, type, pretty, isStopped = false) {
    this.pattern = pattern;
    this.type = type;
    this.pretty = pretty;
    this.isStopped = isStopped;
    this.height = pattern.length;
    this.width = pattern[0].length;
    this.top = 0;
    this.bottom = this.height - 1;
    this.left = 0;
    this.right = this.width - 1;

    return {
        ...this,
        spawn(x, y) {
            this.top = y;
            this.bottom = y + this.height - 1;
            this.left = x;
            this.right = x + this.width - 1;
        },
        fall(dy = 1) {
            this.top += dy;
            this.bottom += dy;
        },
        shift(dx = 0) {
            this.left += dx;
            this.right += dx;
        },
        // local coords
        at(x, y) {
            const row = this.pattern[y] || [];
            return row[x] || SPACE;
        },
        // global coords
        atGlobal(global_x, global_y) {
            return this.at(global_x - this.left, global_y - this.top);
        }
    }
}

// Shape factory
function getShape(index) {
    const _ = SPACE;
    const X = FALLING;
    const types = ["-", "+", "┘", "|", "□"];
    const patterns = [
        [
            [X, X, X, X]
        ],
        [
            [_, X, _],
            [X, X, X],
            [_, X, _]
        ],
        [
            [_, _, X],
            [_, _, X],
            [X, X, X]
        ],
        [
            [X],
            [X],
            [X],
            [X]
        ],
        [
            [X, X],
            [X, X]
        ]
    ];
    return new Shape(patterns[index], types[index]);
}

/**
 * Try to drop a shape by 1 unit, return if it came to rest
 * @param {Shape} shape
 * @returns {String} status "stopped"|"falling"
 */
 function dropShape(shape) {
    // hit the ground?
    if (shape.bottom + 1 === cave.area.length) {
        shape.isStopped = true;
        return "stopped";
    }
    // test what's in cave below last row of shape
    const shapeEdge = shape.pattern[shape.height - 1];
    const caveRow = cave.area[shape.bottom + 1].slice(shape.left, shape.right + 1);
    for (let x = 0; x < shape.width; x++) {
        if (shapeEdge[x] === FALLING && caveRow[x] === ROCK) {
            shape.isStopped = true;
            return "stopped";
        }
    }
    // repeat for 2nd row of "+" shape only
    if (shape.type === "+") {
        const shapeEdge2 = shape.pattern[shape.height - 2];
        const caveRow2 = cave.area[shape.bottom].slice(shape.left, shape.right + 1);
        for (let x = 0; x < shape.width; x++) {
            if (shapeEdge2[x] === FALLING && caveRow2[x] === ROCK) {
                shape.isStopped = true;
                return "stopped";
            }
        }
    }

    shape.fall(1);
    return "falling";
}

/**
 * Push a shape 1 unit left or right by the given jet
 * @param {Shape} shape
 * @param {String} jet "<"|">"
 */
function pushShape(shape, jet) {
    let dx = 0;
    // test against cave walls
    if (jet === LJET && shape.left > 0) {
        dx = -1;
    }
    else if (jet === RJET && shape.right < CAVE_WIDTH - 1) {
        dx = 1;
    }
    // test all shape cells against prospective cave cells
    for (let y = 0; y < shape.height; y++) {
        for (let x = 0; x < shape.width; x++) {
            const s = shape.at(x,y);
            const nb = shape.at(x + dx, y);
            if (s === FALLING && nb === SPACE && cave.area[shape.top + y][shape.left + x + dx] === ROCK) {
                return;
            }
        }
    }
    shape.shift(dx);
}

function Cave() {
    // initialise empty cave
    this.area = [];
    for (let y = 0; y < 4; y++) {
        this.area.push([]);
        for (let x = 0; x < CAVE_WIDTH; x++) {
            this.area[y].push(SPACE);
        }
    }

    return {
        ...this,
        getSpawnPoint() {
            return [2,0];
        },
        // Make cave just tall enough to accommodate next shape
        // Only do this when no moving shapes!
        optimiseHeight(shapeHeight) {
            let high_y = this.area.findIndex(row => row.includes(ROCK));
            if (high_y === -1) return; // empty cave only
            // p({high_y, shapeHeight});
            // reduce if too tall
            while (high_y > shapeHeight + 3) {
                this.area.shift();
                // p('reduced 1')
                high_y--;
            }
            // extend if too short
            while (high_y < shapeHeight + 3) {
                this.area.unshift(Array(CAVE_WIDTH).fill(SPACE));
                // p('extended 1')
                high_y++;
            }
        },
        writeShape(shape) {
            // p('writeShape', shape.type)
            for (let y = shape.top; y <= shape.bottom; y++) {
                for (let x = shape.left; x <= shape.right; x++) {
                    const s = shape.atGlobal(x,y);
                    const c = this.area[y][x];
                    if (s === FALLING && c === ROCK) {
                        console.error(`cannot write ${s} to ${c} at (${x},${y})`);
                        process.exit(1);
                    }
                    if (s === FALLING) {
                        this.area[y][x] = ROCK;
                    }
                }
            }
        },
        print(n, t, shape) {
            p(`\nCave ${n}.${t}:`);
            const height = this.area.length;
            for (let y = 0; y < Math.min(height,15); y++) {
                let row = [];
                for (let x = 0; x < CAVE_WIDTH; x++) {
                    let c = this.area[y][x];
                    if (shape) {
                        let s = shape.atGlobal(x,y);
                        row.push(s === FALLING ? s : c);
                    }
                    else {
                        row.push(c);
                    }
                }
                p('|', row.join(""), '|', height - y);
            }
            p('+ ------- +');
        },
        measureTower() {
            return this.area.length - this.area.findIndex(row => row.includes(ROCK))
        }
    }
}
const cave = new Cave();

// Part 1 - how tall is the tetromino tower after 2022 shapes have stopped?
let n; // number of shapes
let towerHeights = [0]; // for each n
let seenStates = {};
let n1;
let n2;
let statePeriod;

let limit_p1 = 2023;
let limit_p2 = 4001;
for (n = 1; n < limit_p2; n++) {
    const shapeType = (n - 1) % 5; // start with "-" and cycle them
    const shape = getShape(shapeType);
    cave.optimiseHeight(shape.height);
    shape.spawn(...cave.getSpawnPoint());

    let t = 0
    while (t >= 0) {
        pushShape(shape, JETS[(j++) % JETS.length]);
        let status = dropShape(shape);
        if (status === "stopped") {
            cave.writeShape(shape);
            break
        }
        t++;
    }

    // for part 2: collect number of shapes corresponding to heightPeriod
    const h = cave.measureTower();
    const firstRockRow = cave.area.length + 1 - h;
    towerHeights.push(h);

    // compare the serialised state of the cave and its inputs, looking for first repetition
    if (!statePeriod) {
        const stateKey = `${j % JETS.length}-${shapeType}-${cave.area.slice(firstRockRow, firstRockRow + 2720)}`;
        if (stateKey in seenStates) {
            p('repeated states seen at shape', seenStates[stateKey], '&', n);
            n1 = seenStates[stateKey]
            n2 = n;
            statePeriod = n2 - n1;
        }
        seenStates[stateKey] = n;
    }
}
//cave.print(n-1,'end');
p("P1:", n-1, 'shapes gives', towerHeights[n-1], 'height'); // 3179

// Part 2 - how tall after 1000000000000 shapes?
p(n1, 'shapes gave', towerHeights[n1], 'height');
p(n2, 'shapes gave', towerHeights[n2], 'height');

const hdiff = towerHeights[n2] - towerHeights[n1];
p({hdiff});
p({statePeriod});

// count up to teraRock rocks using loops
const teraRock = 1_000_000_000_000;
// pre-repetition
let shapeCtr = n1;
let heightCtr = towerHeights[n1];
// repetition
while (shapeCtr + statePeriod < teraRock) {
    shapeCtr += statePeriod;
    heightCtr += hdiff;
}
// post-repetition
let e = 0;
while (shapeCtr < teraRock) {
    shapeCtr += 1;
    heightCtr += towerHeights[n1 + e + 1] - towerHeights[n1 + e];
    e++;
}
p("P2:", shapeCtr, 'shapes gives', heightCtr, 'height'); // 1567723342929
