const p = console.log

/**
 * @typedef {Number[]} Element
 * @property {Number} 0 - index of element in the input list
 * @property {Number} 1 - value
 */

const fs = require('fs');
const inputList = fs.readFileSync('../inputs/input20.txt', 'utf-8')
    .split("\n")
    .map((line, idx) => [idx, parseInt(line, 10)]);

/**
 * Rearrange circular list so all of it sits after a given element
 * @param {Element[]} list
 * @param {Number} i - index within list which should end up at index 0
 * @returns {Element[]}
 */
function rotateListRight(list, i) {
    const before = list.slice(0, i);
    const i_after = list.slice(i);
    return [...i_after, ...before];
}

/**
 * Rearrange circular list so all of it sits before a given element
 * @param {Element[]} list
 * @param {Number} i - index within list which should end up at index -1
 * @returns {Element[]}
 */
function rotateListLeft(list, i) {
    const before_i = list.slice(0, i+1);
    const after = list.slice(i+1);
    return [...after, ...before_i];
}

/**
 * Moves a given element to a new position in the list, given by its value
 * Wrapping not allowed!
 * @param {Element[]} list
 * @param {Number} i - index of element to be moved
 * @returns {Element[]}
 */
function moveNumberForward(list, i, amt) {
    const n = list[i];
    let newList = [...list];

    if (n === 0) return newList;

    const j = i + amt + 1;

    newList.splice(j, 0, n); // insert new n at j to right of i
    newList.splice(i, 1); // remove old n at original index i
    return newList;
}

/**
 * Moves a given element to a new position in the list, given by its value
 * Wrapping not allowed!
 * @param {Element[]} list
 * @param {Number} i - index of element to be moved
 * @returns {Element[]}
 */
function moveNumberBackward(list, i, amt) {
    const n = list[i];
    let newList = [...list];

    if (n === 0) return newList;

    const j = i - amt;

    newList.splice(j, 0, n); // insert new n at j to left of i, increasing index to remove
    newList.splice(i+1, 1); // remove old n at increased index i    return newList;
    return newList;
}

/**
 * Moves a given element to a new position in the list, given by its value
 * @param {Element[]} list
 * @param {Number} i - index of element to be moved
 * @returns {Element[]}
 */
function moveNumberCyclically(list, idx) {
    const n = list[idx][1];
    const size = list.length;
    let newList = [...list];

    if (n === 0) return newList;

    let dn = Math.abs(n) % (size - 1);

    // move n in stages:
    if (n > 0) {
        newList = rotateListRight(newList, idx); // position element at 0 by rotation
        while (dn > size - 1) {
            newList = moveNumberForward(newList, 0, size - 1); // move it to the very end
            newList = rotateListRight(newList, size - 1); // position it at 0 by rotation
            dn -= size - 1;
        }
        newList = moveNumberForward(newList, 0, dn); // move it the remainder of the way
    }
    else {
        newList = rotateListLeft(newList, idx); // position element at -1 by rotation
        while (dn > size - 1) {
            newList = moveNumberBackward(newList, size - 1, size - 1); // move it to the very start
            newList = rotateListLeft(newList, 0); // position it at -1 by rotation
            dn -= size - 1;
        }
        newList = moveNumberBackward(newList, size - 1, dn); // move it the remainder of the way
    }
    return newList;
}

/**
 * Sum the 1000th, 2000th and 3000th values of the list when 0 is at index 0
 * @param {Element[]} mixedList
 * @returns {Element[]}
 */
function findAnswer(mixedList) {
    const zeroIdx = mixedList.findIndex(itm => itm[1] === 0);
    mixedList = rotateListRight(mixedList, zeroIdx);
    const cleanedList = mixedList.map(itm => itm[1]);
    const a1 = cleanedList[1000 % cleanedList.length];
    const a2 = cleanedList[2000 % cleanedList.length];
    const a3 = cleanedList[3000 % cleanedList.length];
    return a1 + a2 + a3;
}

// Part 1
let mixedList1 = [...inputList];
inputList.forEach(elt => {
    const eltIdx = mixedList1.findIndex(itm => itm[0] === elt[0]);
    mixedList1 = moveNumberCyclically(mixedList1, eltIdx);
});
p('P1:', findAnswer(mixedList1)); // 14526

// Part 2
const decryptionKey = 811589153;
let mixedList2 = [...inputList].map(itm => [itm[0], decryptionKey * itm[1]]);

for (let t = 0; t < 10; t++) {
    inputList.forEach(elt => {
        const eltIdx = mixedList2.findIndex(itm => itm[0] === elt[0]);
        mixedList2 = moveNumberCyclically(mixedList2, eltIdx);
    });
}
p('P2:', findAnswer(mixedList2)); // 9738258246847
