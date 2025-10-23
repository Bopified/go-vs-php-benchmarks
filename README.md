# JSON Encoding/Decoding Benchmark: Go vs PHP

Benchmark comparing JSON encoding and decoding performance across:
- **Go with Sonic** - High-performance JSON library
- **PHP Native** - Built-in json_encode/json_decode
- **PHP with simdjson** - SIMD-accelerated JSON parsing

## Prerequisites

### Go
- Go 1.16 or higher
- Sonic library (automatically installed)

### PHP
- PHP 7.4 or higher
- Optional: simdjson extension for SIMD-accelerated parsing

### Install simdjson (optional)
```bash
pecl install simdjson
```

## Running the Benchmark

Make the script executable and run:
```bash
chmod +x benchmark.sh
./benchmark.sh
```

Or on Windows with Git Bash:
```bash
bash benchmark.sh
```

## What's Being Tested

The benchmark performs 10,000 iterations of:
1. **Decoding**: Parsing JSON string into native data structures
2. **Encoding**: Converting data structures back to JSON string

Test data includes:
- Nested objects (users with addresses)
- Arrays (hobbies)
- Multiple data types (strings, integers, booleans)
- Metadata object

## Expected Results

- **Go (sonic)**: Fastest overall, optimized for both encoding and decoding
- **PHP (native)**: Baseline performance, widely available
- **PHP (simdjson)**: Faster decoding with SIMD instructions, native encoding

## Notes

- simdjson only provides JSON decoding; encoding uses native `json_encode`
- Results may vary based on CPU, system load, and data complexity
- Benchmarks run in-process without external I/O after initial file read
