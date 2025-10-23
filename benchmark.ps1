# JSON Encoding/Decoding Benchmark: Go vs PHP
# Comparing: Go (sonic), PHP (native), PHP (simdjson)

Write-Host "========================================" -ForegroundColor Blue
Write-Host "JSON Encoding/Decoding Benchmark" -ForegroundColor Blue
Write-Host "========================================`n" -ForegroundColor Blue

# Check if files exist, if not create them
if (-not (Test-Path "test_data.json")) {
    Write-Host "Creating test data..." -ForegroundColor Yellow
    @'
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
'@ | Out-File -FilePath "test_data.json" -Encoding UTF8
}

# Initialize Go module if needed
if (-not (Test-Path "go.mod")) {
    Write-Host "Initializing Go module..." -ForegroundColor Yellow
    go mod init json-benchmark | Out-Null
}

# Install Go dependencies if needed
if (-not (Test-Path "go.sum") -or -not (Select-String -Path "go.sum" -Pattern "bytedance/sonic" -Quiet)) {
    Write-Host "Installing Go dependencies..." -ForegroundColor Yellow
    go get github.com/bytedance/sonic | Out-Null
}

# Build Go benchmark
if (-not (Test-Path "benchmark_go.exe") -or ((Get-Item "benchmark_go.go").LastWriteTime -gt (Get-Item "benchmark_go.exe").LastWriteTime)) {
    Write-Host "Building Go benchmark..." -ForegroundColor Yellow
    go build -o benchmark_go.exe benchmark_go.go
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to build Go benchmark!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Running Benchmarks" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Run Go benchmark
Write-Host "--- Go with Sonic ---" -ForegroundColor Cyan
.\benchmark_go.exe
Write-Host ""

# Run PHP native benchmark
Write-Host "--- PHP Native ---" -ForegroundColor Cyan
php benchmark_php_native.php
Write-Host ""

# Run PHP simdjson benchmark
Write-Host "--- PHP with simdjson ---" -ForegroundColor Cyan
php benchmark_php_simdjson.php
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Benchmark Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Note: simdjson only provides decoding. Encoding uses native json_encode." -ForegroundColor Yellow
Write-Host "Install simdjson: pecl install simdjson" -ForegroundColor Yellow
