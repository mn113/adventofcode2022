const p = console.log;

const X_OFFSET = 300; // input data is offset

const fs = require('fs');
const data = fs.readFileSync('../inputs/input14.txt', 'utf-8')
    .split('\n')
    .map(line => line.split('->')
        .map(s => s.trim())
        .map(pair => pair.split(',')
            .map(p => parseInt(p, 10))
        )
        .map(([x,y]) => [x - X_OFFSET, y])
    );

const SPACE = "."
const ROCK = "█"
const SAND = "o"


// initialise empty cave
const max_x = 400;
let cave = [];
for (let y = 0; y < 179; y++) {
    cave.push([]);
    for (let x = 0; x < max_x; x++) {
        cave[y].push(SPACE);
    }
}
// origin
const ORIGIN = { x: 500 - X_OFFSET, y: 0 };
cave[ORIGIN.y][ORIGIN.x] = '*';

// part 2 floor:
cave.push(Array(max_x).fill(ROCK));

let max_y = 0;
// build cave of rock lines
data.forEach(pairs => {
    for (let i = 0; i < pairs.length - 1; i++) {
        const [x0, y0] = pairs[i];
        const [x1, y1] = pairs[i+1];

        high_y = Math.max(y0,y1);
        if (high_y > max_y) {
            max_y = high_y;
        }

        cave[y0][x0] = ROCK;

        // vertical line
        if (x1 === x0) {
            // to up
            if (y0 < y1) {
                for (let ycave = y0; ycave <= y1; ycave++) {
                    cave[ycave][x1] = ROCK;
                }
            }
            // to down
            else {
                for (let ycave = y0; ycave >= y1; ycave--) {
                    cave[ycave][x1] = ROCK;
                }
            }
        }
        // horizontal line
        if (y1 === y0) {
            // to right
            if (x0 < x1) {
                for (let xcave = x0; xcave <= x1; xcave++) {
                    cave[y1][xcave] = ROCK;
                }
            }
            // to left
            else {
                for (let xcave = x0; xcave >= x1; xcave--) {
                    cave[y1][xcave] = ROCK;
                }
            }
        }
    };
});

function print_cave(n) {
    p(`cave ${n}:`);
    cave.forEach((row,y) => p(row.join(""), y));
    p(`cave ${n}.`);
}

let fell_through = false;

function dropSandGrain(n) {
    let sand = {...ORIGIN};
    let settled = false;

    let down = cave[sand.y + 1][sand.x];
    let downLeft = cave[sand.y + 1][sand.x - 1];
    let downRight = cave[sand.y + 1][sand.x + 1];
    // part 2 end condition
    if (down === SAND && downLeft === SAND && downRight === SAND) {
        p('grain', n, 'blocked origin');
        return;
    }

    while (!settled) {
        down = cave[sand.y + 1][sand.x];
        downLeft = cave[sand.y + 1][sand.x - 1];
        downRight = cave[sand.y + 1][sand.x + 1];

        // part 1 end condition
        if (sand.y >= max_y && !fell_through) {
            p('grain', n, 'fell through');
            fell_through = true;
            continue;
        }
        // try go down
        else if (down === SPACE) {
            sand.y += 1;
        }
        // try go down left
        else if (downLeft === SPACE) {
            sand.y += 1;
            sand.x -= 1;
        }
        // try go down right
        else if (downRight === SPACE) {
            sand.y += 1;
            sand.x += 1;
        }
        else {
            settled = true;
            // write to cave
            cave[sand.y][sand.x] = SAND;
        }
    }
}

// Part 1 - how many grains of sand can settle before they just fall through onto floor?
// 1078
// Part 2 - with infinite floor, how many grains can settle before input blocked?
// 30157
let n;
for (n = 1; n <= 30_157; n++) {
    dropSandGrain(n);
}
print_cave(n);
