<?php

$inputFile1 = '../inputs/input22_map.txt';
$inputFile2 = '../inputs/input22_directions.txt';
$map_data = file($inputFile1);
$instr_data = file($inputFile2)[0];

$instrs = str_replace("R", "_R", $instr_data);
$instrs = str_replace("R", "R_", $instrs);
$instrs = str_replace("L", "_L", $instrs);
$instrs = str_replace("L", "L_", $instrs);
$instrs = preg_split("/_/", $instrs);

$side_length = 50; // remember to set this according to demo or real input

// Global map
$map = [];
for ($y = 0; $y < count($map_data); $y++) {
    $map[] = [];
    for ($x = 0; $x < strlen(rtrim($map_data[$y])); $x++) {
        $map[$y][] = $map_data[$y][$x];
    }
    $map[$y] = array_pad($map[$y], 3 * $side_length, ' ');
}
// print_r($map);
$ydim = count($map);
$xdim = count($map[0]);

$history_map = json_decode(json_encode($map));
$history_map[0][$side_length] = 'O';

// Global player - starts at top left of face 1, facing >
$player = [
    'y' => 0,
    'x' => $side_length,
    'facing' => '>'
];


// Dice map, top-left coords:
//   |1|2| face1: 50,0  face2: 100,0
//   |3|   face3: 50,50
// |5|6|   face5: 0,100 face6: 50,100
// |4|     face4: 0,150
function get_face() {
    global $player, $side_length;
    extract($player);

    $fx = floor($x / $side_length);
    $fy = floor($y / $side_length);

    return [
        [null,1,2],
        [null,3],
        [5,6],
        [4],
    ][$fy][$fx];
}


function print_map() {
    global $map, $ydim, $xdim, $player;

    for ($y = 0; $y < $ydim; $y++) {
        for ($x = 0; $x < $xdim; $x++) {
            $c = $map[$y][$x];
            echo $x === $player['x'] && $y === $player['y'] ? $player['facing'] : $c;
        }
        echo "\n";
    }
    echo "\n";
}


function print_history_map() {
    global $history_map, $ydim, $xdim, $side_length;

    for ($y = 0; $y < $ydim; $y++) {
        for ($x = 0; $x < $xdim; $x++) {
            switch ($history_map[$y][$x]) {
                case '<':
                    echo "\e[0m\e[1;31m"; /// _bold_red
                    break;
                case '>':
                    echo "\e[1m\e[1;32m"; // _bold_light_green
                    break;
                case '^':
                    echo "\e[1m\e[1;33m"; // _bold_light_yellow
                    break;
                case 'v':
                    echo "\e[1m\e[1;36m"; // _bold_light_cyan
                    break;
                case '#':
                    echo "\e[1;34m"; //_light_blue
                    break;
                case '.':
                    if ($y % $side_length === 0) echo "\e[0;31m"; // _red
                    else if ($x % $side_length === 0) echo "\e[0;31m"; // _red
                    else echo "\e[1;34m"; // light_blue
                    break;
                case 'E':
                    echo "\e[0;30;47m"; //_grey_on_white
                    break;
            }
            echo $history_map[$y][$x];
            echo "\e[0m"; // end formatting

        }
        echo "\n";
    }
    echo "\n";
}


function turn($right = true) {
    global $player;
    extract($player);

    if ($facing === '>') $player['facing'] = $right ? 'v' : '^';
    else if ($facing === '<') $player['facing'] = $right ? '^' : 'v';
    else if ($facing === '^') $player['facing'] = $right ? '>' : '<';
    else if ($facing === 'v') $player['facing'] = $right ? '<' : '>';
}


function step() {
    global $player, $map, $history_map, $xdim, $ydim, $part;
    extract($player);

    $face = get_face();

    if ($facing === '>') $x++;
    else if ($facing === '<') $x--;
    else if ($facing === 'v') $y++;
    else if ($facing === '^') $y--;

    $stepping_x = in_array($facing, ['<','>']);
    $stepping_y = !$stepping_x;

    if (
        ($stepping_x && ($x < 0 || $x >= $xdim)) ||
        ($stepping_y && ($y < 0 || $y >= $ydim))
    ) {
        $part === 1 ? teleport() : wrap();
    }
    else {
        $c = $map[$y][$x];
        switch ($c) {
            case ".":
                $player['x'] = $x;
                $player['y'] = $y;
                $history_map[$y][$x] = $facing;
                $newface = get_face();
                return;

            case " ":
                $part === 1 ? teleport() : wrap();
                return;

            case "#": // blocked
                return;

            default:
                echo "UNEXPECTED $x $y : '$c'\n";
                print_r($map);
                die();
        }
    }
}


function teleport() {
    global $player, $map, $ydim;
    extract($player);

    if ($facing === '>') {
        $firstwall = strpos(implode('', $map[$y]), '#');
        $firstspace = strpos(implode('', $map[$y]), '.');
        if ($firstwall === false || $firstspace < $firstwall) {
            $player['x'] = $firstspace;
        }
    }
    else if ($facing === '<') {
        $lastwall = strrpos(implode('', $map[$y]), '#', -1);
        $lastspace = strrpos(implode('', $map[$y]), '.', -1);
        if ($lastwall === false || $lastspace > $lastwall) {
            $player['x'] = $lastspace;
        }
    }
    else if ($facing === 'v') {
        $y1 = 0;
        $firstwall = false;
        $firstspace = false;
        while ($firstwall === false && $firstspace === false) {
            if ($map[$y1][$x] === '#') $firstwall = $y1;
            else if ($map[$y1][$x] === '.') $firstspace = $y1;
            $y1++;
        }
        if ($firstspace !== false) {
            $player['y'] = $firstspace;
        }
    }
    else if ($facing === '^') {
        $y1 = $ydim - 1;
        $firstwall = false;
        $firstspace = false;
        while ($firstwall === false && $firstspace === false) {
            if ($map[$y1][$x] === '#') $firstwall = $y1;
            else if ($map[$y1][$x] === '.') $firstspace = $y1;
            $y1--;
        }
        if ($firstspace !== false) {
            $player['y'] = $firstspace;
        }
    }
}


function wrap() {
    global $player, $map, $history_map, $side_length;
    extract($player);

    $face = get_face();

    if ($face === 1) {
        if ($facing === '^') {
            $newface = 4; // map x->y
            $x1 = 0;
            $y1 = $x + (2 * $side_length);
            $newfacing = '>';
        }
        else if ($facing === '<') {
            $newface = 5; // map y->y, reverse
            $x1 = 0;
            $y1 = (3 * $side_length - 1) - $y;
            $newfacing = '>';
        }
    }
    else if ($face === 2) {
        if ($facing === '^') {
            $newface = 4; // map x->x
            $x1 = $x - (2 * $side_length);
            $y1 = (4 * $side_length) - 1;
            $newfacing = '^';
        }
        else if ($facing === '>') {
            $newface = 6; // map y->y, reverse
            $x1 = (2 * $side_length) - 1;
            $y1 = (3 * $side_length - 1) - $y;
            $newfacing = '<';
        }
        else if ($facing === 'v') {
            $newface = 3; // map x->y
            $x1 = (2 * $side_length) - 1;
            $y1 = $x - $side_length;
            $newfacing = '<';
        }
    }
    else if ($face === 3) {
        if ($facing === '<') {
            $newface = 5; // map y->x
            $x1 = $y - $side_length;
            $y1 = 2 * $side_length;
            $newfacing = 'v';
        }
        else if ($facing === '>') {
            $newface = 2; // map y->x
            $x1 = $y + $side_length;
            $y1 = $side_length - 1;
            $newfacing = '^';
        }
    }
    else if ($face === 6) {
        if ($facing === '>') {
            $newface = 2; // map y->y, reverse
            $x1 = 3 * $side_length - 1;
            $y1 = (3 * $side_length - 1) - $y;
            $newfacing = '<';
        }
        else if ($facing === 'v') {
            $newface = 4; // map x->y
            $x1 = $side_length - 1;
            $y1 = $x + (2 * $side_length);
            $newfacing = '<';
        }
    }
    else if ($face === 5) {
        if ($facing === '^') {
            $newface = 3; // map x->y
            $x1 = $side_length;
            $y1 = $x + $side_length;
            $newfacing = '>';
        }
        else if ($facing === '<') {
            $newface = 1; // map y->y, reverse
            $x1 = $side_length;
            $y1 = (3 * $side_length - 1) - $y;
            $newfacing = '>';
        }
    }
    else if ($face === 4) {
        if ($facing === '>') {
            $newface = 6; // map y->x
            $x1 = $y - (2 * $side_length);
            $y1 = 3 * $side_length - 1;
            $newfacing = '^';
        }
        else if ($facing === 'v') {
            $newface = 2; // map x->x
            $x1 = $x + (2 * $side_length);
            $y1 = 0;
            $newfacing = 'v';
        }
        else if ($facing === '<') {
            $newface = 1; // map y->x
            $x1 = $y - (2 * $side_length);
            $y1 = 0;
            $newfacing = 'v';
        }
    }

    $face = get_face();

    # check for wall before moving
    if ($map[$y1][$x1] === '.') {
        $player['x'] = $x1;
        $player['y'] = $y1;
        $player['facing'] = $newfacing;
        $history_map[$y1][$x1] = $newfacing;
    }
}


// change value for part 1/2:
$part = 1;
$i = 0;
foreach ($instrs as $instr) {
    if ($instr === 'R' || $instr === 'L') {
        turn($instr === 'R');
    }
    else {
        $distance = (int) $instr;
        while ($distance > 0) {
            step();
            $distance--;
        }
    }
    $i++;
}
$history_map[$player['y']][$player['x']] = 'E'; // End
print_history_map();

echo "$i / 4001 instructions used.\n";
print_r($player);

// Find the coordinates at the end of the path around the cube
$facing_score = [
    '>' => 0,
    'v' => 1,
    '<' => 2,
    '^' => 3
];
$ans = (1000 * ($player['y'] + 1)) + (4 * ($player['x'] + 1)) + $facing_score[$player['facing']];
print "P$part: $ans\n";
# P1: 88226
# P2: 57305
