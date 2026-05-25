# OrbStack Backend Setup

This guide walks through setting up the KongAir backend services on **OrbStack** for local development and the APIOps demo.

## Prerequisites

- **OrbStack** installed and running
  - Get it from [orbstack.dev](https://orbstack.dev)
  - On first launch, OrbStack sets up an isolated Linux VM and Docker engine
- **Docker Compose** (included with OrbStack)
- This repository cloned locally

### Clone the Repository

If you haven't already cloned the KongAir repository, do so now:

```bash
# Clone from your fork (recommended for the demo)
git clone https://github.com/tomathom15/KongAir.git

# Or clone from the main repository
git clone https://github.com/gwen-kong/KongAir.git

cd KongAir
```

## Quick Start

### 1. Start all backends

From the repo root, start the KongAir services with OrbStack optimizations:

```bash
docker-compose -f docker-compose-orbstack.yaml up -d
```

This starts five services:
- **flights** (port 5052) — Flight search and information
- **routes** (port 5053) — Route definitions
- **bookings** (port 5054) — Booking management
- **customers** (port 5051) — Customer profiles
- **experience** (port 5050) — GraphQL aggregation layer

All services run on the `kong-edu-net` bridge network, so they can reach each other via hostname.

### 2. Verify services are running

```bash
docker-compose -f docker-compose-orbstack.yaml ps
```

### 3. Test connectivity

```bash
# From your Mac, hit the flights service
curl http://localhost:5052/flights

# Or from inside OrbStack
docker exec kongair-flights curl http://flights.kongair:8080/flights
```

### 4. Stop services

```bash
docker-compose -f docker-compose-orbstack.yaml down
```

## Networking

**Key points for the demo:**

- Services are isolated in the `kong-edu-net` bridge network
- Each service has a hostname (e.g., `flights.kongair`) for inter-service communication
- Ports are forwarded from your Mac (5050–5054) to the OrbStack VM
- Kong Gateway will be configured to route requests to these containers

For **local Kong setup**, you would point Kong's upstream services to:
- `http://flights.kongair:8080`
- `http://routes.kongair:8080`
- etc.

## Adding Dark API Endpoints

In Act 1, we add undocumented endpoints to the backends that exist but aren't in any OAS spec or Kong configuration. These will be added to the backend services (e.g., `/flights/search`, `/flights/history`) so traffic can hit them even though Kong doesn't know about them.

TBD: Implementation details as those endpoints are added.

## Troubleshooting

### Services won't start
- Ensure OrbStack is running and Docker is available
- Check disk space: `docker system df`
- View logs: `docker-compose -f docker-compose-orbstack.yaml logs <service-name>`

### Can't reach service from Mac
- Confirm ports are exposed: `docker-compose -f docker-compose-orbstack.yaml ps`
- Test inside OrbStack: `docker exec kongair-flights curl http://flights.kongair:8080/flights`

### Port already in use
- Find what's using the port: `lsof -i :5052`
- Modify the compose file port mapping if needed (left side = Mac port, right side = container port)

## Next Steps

Once backends are running:
1. Set up a [local GitHub Actions runner](actions-runner-setup.md) inside OrbStack
2. Deploy Kong locally and point it to these backends
3. Run the traffic injector to generate demo traffic
