# Quick Start Guide

## Running the Benchmark

### Windows
```powershell
# PowerShell (recommended)
.\benchmark.ps1

# Or Command Prompt
benchmark.bat

# Or Git Bash
bash benchmark.sh
```

### Linux/Mac
```bash
chmod +x benchmark.sh
./benchmark.sh
```

## Sample Output

```
========================================
Running Benchmarks
========================================

--- Go with Sonic ---
Go (sonic) - Iterations: 10000
Decode: 53.947000 ms (avg: 0.005395 ms)
Encode: 12.918000 ms (avg: 0.001292 ms)
Total: 66.865000 ms

--- PHP Native ---
PHP (native) - Iterations: 10000
Decode: 86.718082 ms (avg: 0.008672 ms)
Encode: 20.049572 ms (avg: 0.002005 ms)
Total: 106.767654 ms

--- PHP with simdjson ---
simdjson extension not loaded. Skipping...
```

## Performance Summary

From the results above:
- **Go (sonic)**: ~67ms total (Fastest)
  - Decode: 54ms (1.6x faster than PHP)
  - Encode: 13ms (1.5x faster than PHP)
- **PHP (native)**: ~107ms total
  - Decode: 87ms
  - Encode: 20ms
- **PHP (simdjson)**: Not installed (would improve decode performance)

## Installing simdjson for PHP

### Linux/Mac
```bash
pecl install simdjson
```

### Windows
Download from: https://pecl.php.net/package/simdjson

Then add to php.ini:
```ini
extension=simdjson
```

## Files

- `benchmark.ps1` - PowerShell runner (Windows)
- `benchmark.bat` - Batch runner (Windows)
- `benchmark.sh` - Bash runner (Linux/Mac/Git Bash)
- `benchmark_go.go` - Go implementation with sonic
- `benchmark_php_native.php` - PHP with native json_encode/decode
- `benchmark_php_simdjson.php` - PHP with simdjson
- `test_data.json` - Sample JSON data for benchmarking

## Customization

To adjust the number of iterations, edit the benchmark files:
- Go: Line 42 `iterations := 10000`
- PHP: Line 3 `$iterations = 10000;`
