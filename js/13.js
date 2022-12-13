const fs = require('fs');
const data = fs.readFileSync('../inputs/input13.txt', 'utf-8')
    .split("\n")
    .filter(line => line.trim().length > 0)
    // hack the integer sequence by adding .1 to final digit
    .map(line => line.replace(/(\d+)([^\d]*)$/, "$1.1 $2"))
    .map(JSON.parse);

const p = console.log;

const EQUAL_UNFINISHED ='EQ_UNF';
const EQUAL = 0;
const LEFT_GREATER = 1;
const RIGHT_GREATER = -1;

/**
 * Compare 2 values
 * @param {Number|Array} left
 * @param {Number|Array} right
 * @returns {Number} 1 if left greater, -1 if right greater
 */
function compare(left, right) {
    // both numbers
    if (typeof left === 'number' && typeof right === 'number') {
        // detect the trailing .1
        const final = left !== Math.floor(left) || right !== Math.floor(right);
        if (final) {
            left = Math.floor(left);
            right = Math.floor(right);
        }
        const res = left > right
            ? LEFT_GREATER
            : right > left
                ? RIGHT_GREATER
                : final
                    ? EQUAL
                    : EQUAL_UNFINISHED;
        return res;
    }
    // 1 number, 1 other
    else if (typeof left === 'number') {
        return compare([left], right);
    }
    else if (typeof right === 'number') {
        return compare(left, [right]);
    }
    // 2 arrays
    else {
        for (let i = 0; i < Math.max(left.length, right.length); i++) {
            if (left.length !== right.length) {
                if (i + 1 > left.length) {
                    // left ran out; right greater
                    return RIGHT_GREATER;
                }
                if (i + 1 > right.length) {
                    // right ran out; left greater
                    return LEFT_GREATER;
                }
            }
            const res = compare(left[i], right[i]);
            if (res === EQUAL_UNFINISHED) {
                continue;
            }
            if (res !== 0) {
                return res;
            }
            // loop must continue if terms equal and not final
        }
        // full equality catch-all
        return 0;
    }
}

// Find out how many pairs of line are well-ordered (smaller value before larger)
const wellOrdered = [];
for (let j = 0; j < data.length; j += 2) {
    const left = data[j];
    const right = data[j+1];
    if (compare(left, right) < 0) {
        wellOrdered.push(j/2 + 1);
    }
}
p('P1:', wellOrdered.reduce((a,b) => a + b)); // 5330

// Order all the input lines, and find the divider packets
const DIVIDER1 = [[2]];
const DIVIDER2 = [[6]];

const sorted = [...data, DIVIDER1, DIVIDER2].sort(compare);

const index1 = sorted.findIndex(q => q === DIVIDER1)
const index2 = sorted.findIndex(q => q === DIVIDER2)

p('P2:', (index1 + 1) * (index2 + 1)); // 27648
