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
	iterations := 100000

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
