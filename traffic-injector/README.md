# Traffic Injector

Generates realistic KongAir airline usage patterns to simulate live traffic during the APIOps demo. Makes the dark APIs visible in Kong's traffic logs even though they're undocumented.

## Purpose

During Act 1 of the demo, this tool:
- Generates **10–20 TPS** (transactions per second) across KongAir APIs
- Simulates realistic workflows: flight search → booking → status check
- Hits both **documented and dark API endpoints**
- Makes analytics and metrics "light up" in Kong/Konnect
- Demonstrates that traffic is flowing even before governance is in place

## Traffic Patterns

### Documented Endpoints (70% of traffic)
- **30%** Flight search (by departure/arrival city)
- **20%** Flight details lookup
- **15%** Route listing
- **15%** Customer profile lookup
- **10%** Flight booking
- **10%** Booking status check

### Dark API Endpoints (30% of traffic, optional)
- **5%** `/flights/search` — Undocumented flight search variant
- **3%** `/flights/history/{custID}` — Customer flight history (not in spec)
- **2%** `/flights/{id}/seats` — Seat map query (not in spec)

## Build

```bash
make build
```

Requires Go 1.21+. Compiles to a single binary: `kongair-injector`

## Usage

### Basic (10 TPS for 5 minutes)

```bash
make run
```

Or manually:

```bash
./kongair-injector \
  -url http://localhost:5052 \
  -tps 10 \
  -duration 5m \
  -dark=true
```

### Burst Mode (2x TPS peak, 20% of the time)

```bash
make run-burst
```

TPS spikes to 20 for brief periods, making traffic patterns more interesting:

```bash
./kongair-injector \
  -url http://localhost:5052 \
  -tps 15 \
  -burst 0.3 \
  -duration 5m \
  -dark=true
```

### Light Traffic (5 TPS for 2 minutes)

```bash
make run-light
```

Good for quick testing without overwhelming metrics:

```bash
./kongair-injector \
  -url http://localhost:5052 \
  -tps 5 \
  -duration 2m
```

### Verbose Mode (see each request)

```bash
make run-verbose
```

Logs each request success/failure:

```bash
./kongair-injector \
  -url http://localhost:5052 \
  -tps 10 \
  -duration 2m \
  -dark=true \
  -v
```

## CLI Flags

| Flag | Default | Description |
|------|---------|-------------|
| `-url` | `http://localhost:5052` | Base URL for flights service (or Kong gateway) |
| `-tps` | `10` | Target transactions per second |
| `-duration` | `5m` | How long to run (e.g., `2m`, `30s`, `1h`) |
| `-burst` | `0.2` | Fraction of time to burst at 2x TPS (0-1) |
| `-dark` | `true` | Include undocumented dark API endpoints |
| `-v` | `false` | Verbose logging (one line per request) |

## Output

Every 10 seconds, the injector reports:

```
[45.3s] RPS: 10.1 | Requests: 455 | Failures: 2 (0.4%)
[55.4s] RPS: 10.0 | Requests: 555 | Failures: 2 (0.4%)
```

At completion:

```
=== FINAL STATS ===
Total requests: 3000
Total failures: 5
Failure rate: 0.2%
Average RPS: 10.0
Duration: 5m0.3s
```

## Demo Flow

### Before the talk
```bash
# Minimal warm-up traffic to populate metrics
make run-light &
```

### During Act 1
```bash
# Start robust traffic generation
make run-burst &

# Now as you edit specs in Insomnia and trigger the pipeline,
# Kong's analytics show real traffic with dark API endpoints visible
```

### Stop
```bash
# Ctrl+C to stop, or let it complete
```

## Targeting Kong Gateway vs Direct Backends

By default, the injector targets the **flights service directly** (`-url http://localhost:5052`).

To route through **Kong Gateway** instead:

```bash
./kongair-injector -url http://localhost:8000 -tps 10 -duration 5m -dark=true
```

(Replace `8000` with your Kong proxy port.)

## Performance Characteristics

- **Memory**: ~20MB baseline
- **CPU**: Minimal (throttled by TPS limit, not by compute)
- **Concurrency**: Each request is non-blocking; handles TPS limit gracefully
- **Timeouts**: 5 seconds per request; failures are logged and don't block other requests

## Troubleshooting

### "Connection refused"
- Ensure backends are running: `docker-compose -f docker-compose-orbstack.yaml ps`
- Verify URL is correct: `-url http://localhost:5052` for flights service

### Low RPS (much lower than target)
- Check if requests are timing out (5s limit)
- Run with `-v` to see errors
- Backends may be slow; give them time to respond

### High failure rate
- Check backend logs: `docker-compose logs kongair-flights`
- Some dark API endpoints may return 404 — that's OK and expected
- The injector treats 404 as a success for discovery purposes

## Clean up

```bash
make clean
```

Removes the compiled binary.
