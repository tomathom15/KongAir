# Traffic Injector Setup

The Traffic Injector generates realistic API traffic patterns during the APIOps demo, making analytics and metrics visible even before governance is in place.

## Purpose

The injector:
- **Generates 10–20 transactions per second** across KongAir APIs
- **Simulates realistic workflows**: flight search → booking → status check
- **Hits both documented and dark API endpoints** (30% dark APIs)
- **Makes Kong metrics light up** during Act 1 and Act 2
- **Demonstrates traffic visibility** without governance vs. with governance

## Prerequisites

- **Go 1.21+** installed on your Mac (for building locally)
- **Backend services running**: `docker-compose -f docker-compose-orbstack.yaml ps`
- Go to the traffic-injector directory: `cd traffic-injector`

## Build the Injector

```bash
cd traffic-injector
make build
```

This compiles to a binary: `./kongair-injector`

## Running the Injector

### Option 1: Light Traffic (Quick Test)
For testing with minimal load:

```bash
make run-light
```

- 5 TPS for 2 minutes
- Good for verifying the setup works

### Option 2: Standard Traffic (Act 1 Demo)
For the main demo with realistic patterns:

```bash
make run-burst
```

- 15 TPS average, spikes to 20 TPS
- Runs for 5 minutes
- Includes dark API endpoints (30% of traffic)
- Perfect for showing traffic patterns

### Option 3: Continuous Traffic (Background)
For long-running traffic generation:

```bash
./kongair-injector \
  -url http://localhost:5052 \
  -tps 10 \
  -duration 1h \
  -dark=true &
```

Runs for 1 hour in the background.

### Option 4: Verbose Mode (Debugging)
To see every request:

```bash
make run-verbose
```

Shows success/failure for each request.

## Traffic Distribution

The injector targets:

- **70% documented endpoints** (flights, routes, bookings, customers, etc.)
- **30% dark APIs** (undocumented endpoints that aren't in specs)

Dark APIs include:
- `/flights/search` — Alternative flight search
- `/flights/history/{custID}` — Customer flight history
- `/flights/{id}/seats` — Seat map queries

## Targeting Kong Gateway (Act 2)

When Kong Gateway is running, redirect traffic through the gateway:

```bash
./kongair-injector \
  -url http://localhost:8000 \
  -tps 10 \
  -duration 5m \
  -dark=true
```

This routes through Kong's proxy instead of direct backends, so Kong sees and logs all traffic.

## Demo Workflow

### Before the Demo
Start minimal warm-up traffic:

```bash
cd traffic-injector
make run-light &
```

This populates initial metrics without overwhelming the logs.

### During Act 1 (The Problem)
Start robust traffic generation:

```bash
make run-burst &
```

Now as you demonstrate dark APIs and Kong's lack of governance, the injector generates real traffic that lights up the analytics showing undocumented API usage.

### During Act 2 (The Solution)
Keep the injector running, switch Kong configuration to add governance:

```bash
# Still running from Act 1, now with governance policies visible
curl http://localhost:8001/plugins  # See governance policies in Kong
```

The same traffic now flows through governed endpoints with rate limiting, authentication, and request validation.

### Stop the Injector
Press `Ctrl+C` or let it complete naturally.

## CLI Options Reference

| Flag | Default | Purpose |
|------|---------|---------|
| `-url` | `http://localhost:5052` | Service URL (or Kong gateway at `:8000`) |
| `-tps` | `10` | Transactions per second |
| `-duration` | `5m` | How long to run (e.g., `2m`, `30s`, `1h`) |
| `-burst` | `0.2` | Fraction of time to burst at 2x TPS |
| `-dark` | `true` | Include undocumented dark API endpoints |
| `-v` | `false` | Verbose mode (log each request) |

## Output Example

Every 10 seconds:
```
[45.3s] RPS: 10.1 | Requests: 455 | Failures: 2 (0.4%)
[55.4s] RPS: 10.0 | Requests: 555 | Failures: 2 (0.4%)
```

Final stats:
```
=== FINAL STATS ===
Total requests: 3000
Total failures: 5
Failure rate: 0.2%
Average RPS: 10.0
Duration: 5m0.3s
```

## Troubleshooting

### "Connection refused"
```bash
# Verify backends are running
docker-compose -f docker-compose-orbstack.yaml ps

# Check the flights service specifically
curl http://localhost:5052/flights
```

### Low RPS (much lower than target)
- Check if requests are timing out (5s limit per request)
- Run with `-v` to see errors: `./kongair-injector -v -tps 10 -duration 1m`
- Backends may be responding slowly

### High failure rate
- Run with verbose to see which endpoints fail
- Some dark APIs return 404 (expected and OK)
- Check backend logs: `docker logs kongair-flights`

### Injector won't build
- Ensure Go 1.21+ is installed: `go version`
- Run from the traffic-injector directory: `cd traffic-injector`

## Performance

- **Memory**: ~20MB baseline
- **CPU**: Minimal (throttled by TPS limit)
- **Network**: Depends on TPS (10 TPS ≈ negligible impact)
- **Per-request timeout**: 5 seconds

## More Information

For detailed usage and traffic patterns, see [traffic-injector/README.md](../traffic-injector/README.md)
