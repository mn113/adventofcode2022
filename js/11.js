const fs = require('fs');
const data = fs.readFileSync('../inputs/input11.txt', 'utf-8').split("\n");

const p = console.log;

const monkeys = [];
let superModulo = 1;

function Monkey(id, items, op, test, trueDest, falseDest) {
    this.inspections = 0;

    return {
        id,
        items,
        inspections: this.inspections,
        inspect(itm) {
            this.inspections++;
            return op(itm);
        },
        test(itm) {
            return test(itm) ? trueDest : falseDest;
        }
    }
}

// Worry reduction step
function ownerInspect(item, part = 1) {
    if (part === 1) {
        return Math.floor(item / 3);
    }
    return item % superModulo;
}

// Let all monkeys process all their items
function playRound(part = 1) {
    monkeys.forEach(monkey => {
        monkey.items.forEach(item => {
            // apply monkey operation
            item = monkey.inspect(item);
            // apply owner operation
            item = ownerInspect(item, part);
            // perform monkey test
            const dest = monkey.test(item);
            // throw
            monkeys.find(m => m.id === dest).items.push(item);
        });
        // all thrown
        monkey.items = [];
    });
}

// Build monkeys list
{
    // Monkey params:
    let id, items, op, test, trueDest, falseDest;
    data.forEach(line => {
        line = line.trim();
        let matches;

        if (line.startsWith('Monkey')) {
            matches = line.match(/(\d+)/);
            id = parseInt(matches[1]);
        }
        else if (line.startsWith('Starting')) {
            matches = line.match(/(\d[\d,\s]*\d?)/);
            items = JSON.parse(`[${matches[1]}]`);
        }
        else if (line.startsWith('Operation')) {
            matches = line.match(/Operation: (.*)/);
            let equation = matches[1].replace('new', 'noo');
            op = ((old, noo) => {
                eval(equation);
                return noo;
            });
        }
        else if (line.startsWith('Test')) {
            matches = line.match(/Test: divisible by (\d+)/);
            let divisor = parseInt(matches[1]);
            test = x => x % divisor === 0;
            superModulo *= divisor;
        }
        else if (line.startsWith('If true')) {
            matches = line.match(/(\d+)/);
            trueDest = parseInt(matches[1]);
        }
        else if (line.startsWith('If false')) {
            matches = line.match(/(\d+)/);
            falseDest = parseInt(matches[1]);
        }
        else if (!line.length) {
            monkeys.push(new Monkey(id, items, op, test, trueDest, falseDest));
            id = items = op = test = trueDest = falseDest = null;
        }
    });
}

// Find the 2 most active monkeys & their business
function getMonkeyBusiness() {
    const activeMonkeys = monkeys.map(m => m.inspections).sort((a,b) => b - a);
    return activeMonkeys.slice(0,2).reduce((a,b) => a * b);
}

// Play 20 rounds - with standard owner worry reduction
function part1() {
    for (let i = 0; i < 20; i++) {
        playRound(1);
    }
    p('P1:', getMonkeyBusiness()); // 69918
}

// Play 10000 rounds - with cleverer owner worry reduction
function part2() {
    for (let i = 0; i < 10000; i++) {
        playRound(2);
    }
    p('P2:', getMonkeyBusiness()); // 19573408701
}

// edit to run:
part2();