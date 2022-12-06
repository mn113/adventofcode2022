<?php

$inputFile = '../inputs/input06.txt';
$data = file($inputFile)[0];

# Find the string offset of the last of N unique consecutive characters
function find_unique_chain_end($chain, $subchain_length) {
    $i = 0;
    while ($i + $subchain_length <= strlen($chain)) {
        $subchain = substr($chain, $i, $subchain_length);
        $uniq_chars = count_chars($subchain, 3);
        if (strlen($uniq_chars) == $subchain_length) {
            break;
        }
        $i++;
    }
    return $i + $subchain_length;
}

$p1 = find_unique_chain_end($data, 4);
$p2 = find_unique_chain_end($data, 14);
print "P1: $p1\n"; # 1876
print "P2: $p2\n"; # 2202
