const fs = require('fs');

const data = fs.readFileSync('../inputs/input07.txt', 'utf-8');
const lines = data.split("\n");

const p = console.log;

let currentPath;
const dirs = {
    root: { size: 0 }
};

// Applies 'cd ..' on a stringified path
function parent(pathStr) {
    if (pathStr.includes('/')) {
        return pathStr.split('/').slice(0,-1).join('/');
    }
    return '';
}

// Applies 'cd subdir' on a stringified path
function child(pathStr, subdir) {
    return `${pathStr}/${subdir}`;
}

// Build up a filesystem
lines.forEach(line => {
    if (line === '$ cd /') { // first line only
        currentPath = 'root';
    }
    else if (line === '$ cd ..') {
        currentPath = parent(currentPath);
    }
    else if (line.startsWith('$ cd ')) {
        const subdir = line.substring(5);
        currentPath = child(currentPath, subdir);
    }
    else if (line.startsWith('dir ')) {
        const dirName = line.substring(4);
        dirs[`${currentPath}/${dirName}`] = { size: 0 };
    }
    else if (line.match(/^\d/)) {
        const [bytes, fileName] = line.split(' ');

        dirs[currentPath].size += +bytes;

        // Also add bytes onto every parent dir
        let tmpPath = parent(currentPath);
        while (tmpPath.length) {
            dirs[tmpPath].size += +bytes;
            tmpPath = parent(tmpPath);
        }
    }
});

// Find sum of all dir sizes up to 100kB
//p(dirs);
p('P1:', Object.values(dirs).map(o => o.size).filter(size => size <= 100000).reduce((a,b) => a + b)); // 1642503

// Find smallest dir to delete to free up space
const space = 70000000;
const space_needed = 30000000;
const space_used = dirs['root'].size;
const to_delete = space_needed - (space - space_used);
p('P2:', Object.values(dirs).map(o => o.size).filter(size => size >= to_delete).sort((a,b) => a - b)[0]); // 6999588
