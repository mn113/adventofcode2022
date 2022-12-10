<?php

$inputFile = '../inputs/input04.txt';
$data = file($inputFile);

$pairs = array_map(function($line) {
    preg_match('/^(\d+)-(\d+),(\d+)-(\d+)$/', $line, $matches);
    return [[
        intval($matches[1]),
        intval($matches[2])
    ], [
        intval($matches[3]),
        intval($matches[4])
    ]];
}, $data);

// Returns true if first range fully contains second
function range_contains_other($r1, $r2) {
    return $r1[0] <= $r2[0] && $r1[1] >= $r2[1];
}

// Returns true if first range precedes and overlaps (or fully contains) second
function range_overlaps_other($r1, $r2) {
    return $r1[0] <= $r2[0] && $r1[1] >= $r2[0];
}

// Find the number of pairs in which one range fully contains the other
$p1 = count(array_filter($pairs, function($pair) {
    return range_contains_other($pair[0], $pair[1]) || range_contains_other($pair[1], $pair[0]);
}));
print "P1: $p1\n"; # 441

// Find the number of pairs in which one range overlaps or fully contains the other
$p2 = count(array_filter($pairs, function($pair) {
    return range_overlaps_other($pair[0], $pair[1]) || range_overlaps_other($pair[1], $pair[0]);
}));
print "P2: $p2\n"; # 861
