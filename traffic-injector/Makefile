.PHONY: build run help clean run-us run-au run-us-burst run-au-burst

help:
	@echo "Traffic Injector for KongAir Demo"
	@echo ""
	@echo "Targets:"
	@echo "  build          - Compile the traffic injector binary"
	@echo ""
	@echo "Direct Backends (for testing):"
	@echo "  run            - Run against flights service (10 TPS for 5 minutes)"
	@echo "  run-burst      - Run against flights service with burst traffic (20 TPS peak)"
	@echo "  run-light      - Run light traffic (5 TPS for 2 minutes)"
	@echo "  run-verbose    - Run with verbose logging"
	@echo ""
	@echo "Kong Gateways (APIOps Helsinki):"
	@echo "  run-us         - Run against US Kong gateway (15 TPS with bursts)"
	@echo "  run-au         - Run against AU Kong gateway (15 TPS with bursts)"
	@echo ""
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

# Kong Gateway targets (APIOps Helsinki)
run-us: build
	./kongair-injector -url http://kong-apiops-helsinki-us.orb.local:8000 -tps 15 -burst 0.3 -duration 5m -dark=true

run-au: build
	./kongair-injector -url http://kong-apiops-helsinki-au.orb.local:8000 -tps 15 -burst 0.3 -duration 5m -dark=true

run-us-burst: build
	./kongair-injector -url http://kong-apiops-helsinki-us.orb.local:8000 -tps 20 -burst 0.5 -duration 10m -dark=true

run-au-burst: build
	./kongair-injector -url http://kong-apiops-helsinki-au.orb.local:8000 -tps 20 -burst 0.5 -duration 10m -dark=true

clean:
	rm -f kongair-injector
