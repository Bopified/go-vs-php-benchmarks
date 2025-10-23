#!/bin/bash

# JSON Encoding/Decoding Benchmark: Go vs PHP
# Comparing: Go (sonic), PHP (native), PHP (simdjson)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}JSON Encoding/Decoding Benchmark${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create test data
echo -e "${YELLOW}Creating test data...${NC}"
cat > test_data.json << 'EOF'
{
  "users": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "age": 30,
      "address": {
        "street": "123 Main St",
        "city": "New York",
        "zipcode": "10001"
      },
      "hobbies": ["reading", "gaming", "hiking"],
      "active": true
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "age": 25,
      "address": {
        "street": "456 Oak Ave",
        "city": "Los Angeles",
        "zipcode": "90001"
      },
      "hobbies": ["cooking", "painting", "yoga"],
      "active": true
    },
    {
      "id": 3,
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "age": 35,
      "address": {
        "street": "789 Pine Rd",
        "city": "Chicago",
        "zipcode": "60601"
      },
      "hobbies": ["photography", "traveling", "music"],
      "active": false
    }
  ],
  "metadata": {
    "total": 3,
    "page": 1,
    "per_page": 10,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
EOF

# Create Go benchmark with sonic
echo -e "${YELLOW}Creating Go benchmark (with sonic)...${NC}"
cat > benchmark_go.go << 'EOF'
package main

import (
	"fmt"
	"os"
	"time"

	"github.com/bytedance/sonic"
)

type Address struct {
	Street  string `json:"street"`
	City    string `json:"city"`
	Zipcode string `json:"zipcode"`
}

type User struct {
	ID      int      `json:"id"`
	Name    string   `json:"name"`
	Email   string   `json:"email"`
	Age     int      `json:"age"`
	Address Address  `json:"address"`
	Hobbies []string `json:"hobbies"`
	Active  bool     `json:"active"`
}

type Metadata struct {
	Total   int    `json:"total"`
	Page    int    `json:"page"`
	PerPage int    `json:"per_page"`
	Time    string `json:"timestamp"`
}

type Data struct {
	Users    []User   `json:"users"`
	Metadata Metadata `json:"metadata"`
}

func main() {
	iterations := 10000

	// Read test data
	jsonData, err := os.ReadFile("test_data.json")
	if err != nil {
		panic(err)
	}

	// Decode benchmark
	var totalDecodeTime time.Duration
	for i := 0; i < iterations; i++ {
		var data Data
		start := time.Now()
		err := sonic.Unmarshal(jsonData, &data)
		totalDecodeTime += time.Since(start)
		if err != nil {
			panic(err)
		}
	}

	// Encode benchmark
	var data Data
	sonic.Unmarshal(jsonData, &data)
	
	var totalEncodeTime time.Duration
	for i := 0; i < iterations; i++ {
		start := time.Now()
		_, err := sonic.Marshal(data)
		totalEncodeTime += time.Since(start)
		if err != nil {
			panic(err)
		}
	}

	fmt.Printf("Go (sonic) - Iterations: %d\n", iterations)
	fmt.Printf("Decode: %.6f ms (avg: %.6f ms)\n", 
		float64(totalDecodeTime.Microseconds())/1000.0,
		float64(totalDecodeTime.Microseconds())/float64(iterations)/1000.0)
	fmt.Printf("Encode: %.6f ms (avg: %.6f ms)\n", 
		float64(totalEncodeTime.Microseconds())/1000.0,
		float64(totalEncodeTime.Microseconds())/float64(iterations)/1000.0)
	fmt.Printf("Total: %.6f ms\n", 
		float64(totalDecodeTime.Microseconds()+totalEncodeTime.Microseconds())/1000.0)
}
EOF

# Create PHP benchmark (native)
echo -e "${YELLOW}Creating PHP benchmark (native)...${NC}"
cat > benchmark_php_native.php << 'EOF'
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
EOF

# Create PHP benchmark (simdjson)
echo -e "${YELLOW}Creating PHP benchmark (simdjson)...${NC}"
cat > benchmark_php_simdjson.php << 'EOF'
<?php

if (!extension_loaded('simdjson')) {
    echo "simdjson extension not loaded. Skipping...\n";
    exit(0);
}

$iterations = 10000;

// Read test data
$jsonData = file_get_contents('test_data.json');

// Decode benchmark
$totalDecodeTime = 0;
for ($i = 0; $i < $iterations; $i++) {
    $start = microtime(true);
    $data = simdjson_decode($jsonData, true);
    $totalDecodeTime += microtime(true) - $start;
}

// Encode benchmark (simdjson only does decoding, use native encoding)
$data = simdjson_decode($jsonData, true);
$totalEncodeTime = 0;
for ($i = 0; $i < $iterations; $i++) {
    $start = microtime(true);
    $encoded = json_encode($data);
    $totalEncodeTime += microtime(true) - $start;
}

printf("PHP (simdjson decode + native encode) - Iterations: %d\n", $iterations);
printf("Decode: %.6f ms (avg: %.6f ms)\n", 
    $totalDecodeTime * 1000, 
    ($totalDecodeTime * 1000) / $iterations);
printf("Encode: %.6f ms (avg: %.6f ms)\n", 
    $totalEncodeTime * 1000, 
    ($totalEncodeTime * 1000) / $iterations);
printf("Total: %.6f ms\n", 
    ($totalDecodeTime + $totalEncodeTime) * 1000);
EOF

# Initialize Go module
echo -e "${YELLOW}Initializing Go module...${NC}"
if [ ! -f "go.mod" ]; then
    go mod init json-benchmark
fi

echo -e "${YELLOW}Installing Go dependencies...${NC}"
go get github.com/bytedance/sonic

# Build Go benchmark
echo -e "${YELLOW}Building Go benchmark...${NC}"
go build -o benchmark_go benchmark_go.go

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Running Benchmarks${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Run Go benchmark
echo -e "${BLUE}--- Go with Sonic ---${NC}"
./benchmark_go
echo ""

# Run PHP native benchmark
echo -e "${BLUE}--- PHP Native ---${NC}"
php benchmark_php_native.php
echo ""

# Run PHP simdjson benchmark
echo -e "${BLUE}--- PHP with simdjson ---${NC}"
php benchmark_php_simdjson.php
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Benchmark Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Note: simdjson only provides decoding. Encoding uses native json_encode.${NC}"
echo -e "${YELLOW}Install simdjson: pecl install simdjson${NC}"
