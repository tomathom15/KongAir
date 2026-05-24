.PHONY: build run help clean

help:
	@echo "Traffic Injector for KongAir Demo"
	@echo ""
	@echo "Targets:"
	@echo "  build          - Compile the traffic injector binary"
	@echo "  run            - Run with default settings (10 TPS for 5 minutes)"
	@echo "  run-burst      - Run with burst traffic (20 TPS peak)"
	@echo "  run-light      - Run light traffic (5 TPS for 2 minutes)"
	@echo "  clean          - Remove binary"
	@echo ""

build:
	go build -o kongair-injector main.go

run: build
	./kongair-injector -url http://localhost:5052 -tps 10 -duration 5m -dark=true

run-burst: build
	./kongair-injector -url http://localhost:5052 -tps 15 -burst 0.3 -duration 5m -dark=true

run-light: build
	./kongair-injector -url http://localhost:5052 -tps 5 -duration 2m -dark=false

run-verbose: build
	./kongair-injector -url http://localhost:5052 -tps 10 -duration 2m -dark=true -v

clean:
	rm -f kongair-injector
