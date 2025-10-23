@echo off
REM JSON Encoding/Decoding Benchmark: Go vs PHP
REM Comparing: Go (sonic), PHP (native), PHP (simdjson)

echo ========================================
echo JSON Encoding/Decoding Benchmark
echo ========================================
echo.

REM Create test data
echo Creating test data...
(
echo {
echo   "users": [
echo     {
echo       "id": 1,
echo       "name": "John Doe",
echo       "email": "john@example.com",
echo       "age": 30,
echo       "address": {
echo         "street": "123 Main St",
echo         "city": "New York",
echo         "zipcode": "10001"
echo       },
echo       "hobbies": ["reading", "gaming", "hiking"],
echo       "active": true
echo     },
echo     {
echo       "id": 2,
echo       "name": "Jane Smith",
echo       "email": "jane@example.com",
echo       "age": 25,
echo       "address": {
echo         "street": "456 Oak Ave",
echo         "city": "Los Angeles",
echo         "zipcode": "90001"
echo       },
echo       "hobbies": ["cooking", "painting", "yoga"],
echo       "active": true
echo     },
echo     {
echo       "id": 3,
echo       "name": "Bob Johnson",
echo       "email": "bob@example.com",
echo       "age": 35,
echo       "address": {
echo         "street": "789 Pine Rd",
echo         "city": "Chicago",
echo         "zipcode": "60601"
echo       },
echo       "hobbies": ["photography", "traveling", "music"],
echo       "active": false
echo     }
echo   ],
echo   "metadata": {
echo     "total": 3,
echo     "page": 1,
echo     "per_page": 10,
echo     "timestamp": "2024-01-15T10:30:00Z"
echo   }
echo }
) > test_data.json

REM Create Go benchmark with sonic
echo Creating Go benchmark ^(with sonic^)...
(
echo package main
echo.
echo import ^(
echo 	"fmt"
echo 	"os"
echo 	"time"
echo.
echo 	"github.com/bytedance/sonic"
echo ^)
echo.
echo type Address struct {
echo 	Street  string `json:"street"`
echo 	City    string `json:"city"`
echo 	Zipcode string `json:"zipcode"`
echo }
echo.
echo type User struct {
echo 	ID      int      `json:"id"`
echo 	Name    string   `json:"name"`
echo 	Email   string   `json:"email"`
echo 	Age     int      `json:"age"`
echo 	Address Address  `json:"address"`
echo 	Hobbies []string `json:"hobbies"`
echo 	Active  bool     `json:"active"`
echo }
echo.
echo type Metadata struct {
echo 	Total   int    `json:"total"`
echo 	Page    int    `json:"page"`
echo 	PerPage int    `json:"per_page"`
echo 	Time    string `json:"timestamp"`
echo }
echo.
echo type Data struct {
echo 	Users    []User   `json:"users"`
echo 	Metadata Metadata `json:"metadata"`
echo }
echo.
echo func main^(^) {
echo 	iterations := 10000
echo.
echo 	// Read test data
echo 	jsonData, err := os.ReadFile^("test_data.json"^)
echo 	if err != nil {
echo 		panic^(err^)
echo 	}
echo.
echo 	// Decode benchmark
echo 	var totalDecodeTime time.Duration
echo 	for i := 0; i ^< iterations; i++ {
echo 		var data Data
echo 		start := time.Now^(^)
echo 		err := sonic.Unmarshal^(jsonData, ^&data^)
echo 		totalDecodeTime += time.Since^(start^)
echo 		if err != nil {
echo 			panic^(err^)
echo 		}
echo 	}
echo.
echo 	// Encode benchmark
echo 	var data Data
echo 	sonic.Unmarshal^(jsonData, ^&data^)
echo 	
echo 	var totalEncodeTime time.Duration
echo 	for i := 0; i ^< iterations; i++ {
echo 		start := time.Now^(^)
echo 		_, err := sonic.Marshal^(data^)
echo 		totalEncodeTime += time.Since^(start^)
echo 		if err != nil {
echo 			panic^(err^)
echo 		}
echo 	}
echo.
echo 	fmt.Printf^("Go ^(sonic^) - Iterations: %%d\n", iterations^)
echo 	fmt.Printf^("Decode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo 		float64^(totalDecodeTime.Microseconds^(^)^)/1000.0,
echo 		float64^(totalDecodeTime.Microseconds^(^)^)/float64^(iterations^)/1000.0^)
echo 	fmt.Printf^("Encode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo 		float64^(totalEncodeTime.Microseconds^(^)^)/1000.0,
echo 		float64^(totalEncodeTime.Microseconds^(^)^)/float64^(iterations^)/1000.0^)
echo 	fmt.Printf^("Total: %%.6f ms\n", 
echo 		float64^(totalDecodeTime.Microseconds^(^)+totalEncodeTime.Microseconds^(^)^)/1000.0^)
echo }
) > benchmark_go.go

REM Create PHP benchmark ^(native^)
echo Creating PHP benchmark ^(native^)...
(
echo ^<?php
echo.
echo $iterations = 10000;
echo.
echo // Read test data
echo $jsonData = file_get_contents^('test_data.json'^);
echo.
echo // Decode benchmark
echo $totalDecodeTime = 0;
echo for ^($i = 0; $i ^< $iterations; $i++^) {
echo     $start = microtime^(true^);
echo     $data = json_decode^($jsonData, true^);
echo     $totalDecodeTime += microtime^(true^) - $start;
echo }
echo.
echo // Encode benchmark
echo $data = json_decode^($jsonData, true^);
echo $totalEncodeTime = 0;
echo for ^($i = 0; $i ^< $iterations; $i++^) {
echo     $start = microtime^(true^);
echo     $encoded = json_encode^($data^);
echo     $totalEncodeTime += microtime^(true^) - $start;
echo }
echo.
echo printf^("PHP ^(native^) - Iterations: %%d\n", $iterations^);
echo printf^("Decode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo     $totalDecodeTime * 1000, 
echo     ^($totalDecodeTime * 1000^) / $iterations^);
echo printf^("Encode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo     $totalEncodeTime * 1000, 
echo     ^($totalEncodeTime * 1000^) / $iterations^);
echo printf^("Total: %%.6f ms\n", 
echo     ^($totalDecodeTime + $totalEncodeTime^) * 1000^);
) > benchmark_php_native.php

REM Create PHP benchmark ^(simdjson^)
echo Creating PHP benchmark ^(simdjson^)...
(
echo ^<?php
echo.
echo if ^(^!extension_loaded^('simdjson'^)^) {
echo     echo "simdjson extension not loaded. Skipping...\n";
echo     exit^(0^);
echo }
echo.
echo $iterations = 10000;
echo.
echo // Read test data
echo $jsonData = file_get_contents^('test_data.json'^);
echo.
echo // Decode benchmark
echo $totalDecodeTime = 0;
echo for ^($i = 0; $i ^< $iterations; $i++^) {
echo     $start = microtime^(true^);
echo     $data = simdjson_decode^($jsonData, true^);
echo     $totalDecodeTime += microtime^(true^) - $start;
echo }
echo.
echo // Encode benchmark ^(simdjson only does decoding, use native encoding^)
echo $data = simdjson_decode^($jsonData, true^);
echo $totalEncodeTime = 0;
echo for ^($i = 0; $i ^< $iterations; $i++^) {
echo     $start = microtime^(true^);
echo     $encoded = json_encode^($data^);
echo     $totalEncodeTime += microtime^(true^) - $start;
echo }
echo.
echo printf^("PHP ^(simdjson decode + native encode^) - Iterations: %%d\n", $iterations^);
echo printf^("Decode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo     $totalDecodeTime * 1000, 
echo     ^($totalDecodeTime * 1000^) / $iterations^);
echo printf^("Encode: %%.6f ms ^(avg: %%.6f ms^)\n", 
echo     $totalEncodeTime * 1000, 
echo     ^($totalEncodeTime * 1000^) / $iterations^);
echo printf^("Total: %%.6f ms\n", 
echo     ^($totalDecodeTime + $totalEncodeTime^) * 1000^);
) > benchmark_php_simdjson.php

REM Initialize Go module
echo Initializing Go module...
if not exist "go.mod" (
    go mod init json-benchmark
)

echo Installing Go dependencies...
go get github.com/bytedance/sonic

REM Build Go benchmark
echo Building Go benchmark...
go build -o benchmark_go.exe benchmark_go.go

echo.
echo ========================================
echo Running Benchmarks
echo ========================================
echo.

REM Run Go benchmark
echo --- Go with Sonic ---
benchmark_go.exe
echo.

REM Run PHP native benchmark
echo --- PHP Native ---
php benchmark_php_native.php
echo.

REM Run PHP simdjson benchmark
echo --- PHP with simdjson ---
php benchmark_php_simdjson.php
echo.

echo ========================================
echo Benchmark Complete!
echo ========================================
echo.
echo Note: simdjson only provides decoding. Encoding uses native json_encode.
echo Install simdjson: pecl install simdjson
