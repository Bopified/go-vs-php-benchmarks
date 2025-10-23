<?php

$iterations = 10000;

// Read test data
$jsonData = file_get_contents('test_data.json');

// Decode benchmark
$totalDecodeTime = 0;
for ($i = 0; $i < $iterations; $i++) {
    $start = microtime(true);
    $data = json_decode($jsonData, true);
    $totalDecodeTime += microtime(true) - $start;
}

// Encode benchmark
$data = json_decode($jsonData, true);
$totalEncodeTime = 0;
for ($i = 0; $i < $iterations; $i++) {
    $start = microtime(true);
    $encoded = json_encode($data);
    $totalEncodeTime += microtime(true) - $start;
}

printf("PHP (native) - Iterations: %d\n", $iterations);
printf("Decode: %.6f ms (avg: %.6f ms)\n", 
    $totalDecodeTime * 1000, 
    ($totalDecodeTime * 1000) / $iterations);
printf("Encode: %.6f ms (avg: %.6f ms)\n", 
    $totalEncodeTime * 1000, 
    ($totalEncodeTime * 1000) / $iterations);
printf("Total: %.6f ms\n", 
    ($totalDecodeTime + $totalEncodeTime) * 1000);
