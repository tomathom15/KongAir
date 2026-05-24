# KongAir — APIOps Demo for Helsinki

This repository is the demo environment for **APIOps Meetup Helsinki** — a live presentation on API Governance and the journey from discovering "dark APIs" to enforcing platform standards.

## The Two-Act Demo

### Act 1: The Problem
APIs exist and are running, but nobody knows what's really there. This act showcases the **discovery problem**:
- Undocumented API endpoints in production (dark APIs)
- Inconsistent response formats and error handling
- No governance, no contracts, no visibility
- Difficult to discover, maintain, and monitor

Run on the `main` branch with undocumented, ungoverned endpoints.

### Act 2: The Solution
The same APIs, now properly standardized and governed:
- APIs documented with OpenAPI specifications
- Service contracts enforced through Kong Konnect
- Governance policies applied at the gateway level
- Improved discoverability, monitoring, and compliance

Run on the `act2-standardized-services` branch with standardized, governed APIs.

## Two-Branch Strategy

- **`main`** — Act 1 demo (dark APIs, no governance)
- **`act2-standardized-services`** — Act 2 demo (standardized, governed APIs)

Both branches run the same backend services and Kong Gateway. The difference is in documentation and governance policies applied through Kong Konnect.

## Architecture

- **Local backends**: KongAir services running via Docker Compose on OrbStack
- **Kong Gateway**: Connected to Konnect for centralized configuration management
- **Traffic injector**: Generates realistic airline usage patterns (10 TPS)
- **Konnect control plane**: Manages Kong configuration for both acts

## Quick Start

### Run the Demo

See [demo_instructions/README.md](demo_instructions/README.md) for complete setup instructions.

```bash
# Start Act 1 (the problem)
./demo_instructions/start-demo-act1.sh

# Or switch to Act 2 (the solution)
./demo_instructions/start-demo-act2.sh

# Stop the demo
./demo_instructions/stop-demo.sh
```

For a detailed walkthrough with curl examples and troubleshooting, see [demo_instructions/demo-walkthrough.md](demo_instructions/demo-walkthrough.md).

## Repository Structure

```
tomathom15/KongAir
├── services/                    # Backend microservices
│   ├── flight-data/            # Flights and routes APIs
│   ├── sales/                  # Bookings and customer services
│   ├── experience/             # Customer experience layer
│   ├── seating/                # Seating management (Act 1: dark APIs)
│   ├── operations/             # Flight operations (Act 1: dark APIs)
│   └── ancillary/              # Add-ons and services (Act 1: dark APIs)
├── infrastructure/              # Gateway and platform configs
│   ├── kong/                   # Kong service definitions
│   │   ├── seating-service.yaml
│   │   ├── operations-service.yaml
│   │   └── ancillary-service.yaml
│   └── terraform/              # Konnect provisioning
├── traffic-injector/           # Generates realistic API load
├── demo_instructions/          # Demo scripts and walkthroughs
│   ├── README.md              # Demo overview
│   ├── start-demo-act1.sh     # Initialize Act 1 environment
│   ├── start-demo-act2.sh     # Initialize Act 2 environment
│   ├── stop-demo.sh           # Clean up services
│   └── demo-walkthrough.md    # Step-by-step manual guide
├── scripts/                    # Deployment and utility scripts
├── docs/                       # Setup guides
├── .github/workflows/          # GitHub Actions CI/CD pipelines
├── docker-compose-orbstack.yaml # OrbStack setup (ARM64)
└── docker-compose.yaml         # Standard Docker Compose setup
```

## Dark API Services (Act 1)

In Act 1, three services expose dark (undocumented) APIs that aren't properly cataloged:

### Seating Service
- `GET /flights/{flightId}/seatingMap` — Get aircraft seating layout
- `GET /flights/{flightId}/seats` — Get available seats

### Operations Service
- `GET /flights/{flightId}/status` — Get flight status
- `GET /flights/{flightId}/crew` — Get crew information
- `GET /flights/{flightId}/gate` — Get gate assignment

### Ancillary Service
- `GET /bookings/{bookingId}/add-ons` — Get add-ons for booking
- `POST /bookings/{bookingId}/add-ons` — Add services to booking
- `GET /routes/{routeId}/baggage-policy` — Get baggage policy
- `GET /flights/{flightId}/meals` — Get meal options
- `GET /customer/{customerId}/meal-preferences` — Get customer preferences

In Act 1, these endpoints work but:
- Are not documented in OpenAPI specs
- Are not configured in Kong Konnect
- Have no governance, rate limiting, or validation
- Are difficult to discover without source code inspection

In Act 2, these same endpoints are standardized with proper documentation and governance.

## APIOps Workflows

GitHub Actions workflows support the demo pipeline:
- [stage-changes-for-kong.yaml](.github/workflows/stage-changes-for-kong.yaml) — Full APIOps pipeline
- [apply-terraform.yaml](.github/workflows/apply-terraform.yaml) — Konnect provisioning
- [docker.yaml](.github/workflows/docker.yaml) — Build and push services
- [stage-kong-for-PRD.yaml](.github/workflows/stage-kong-for-PRD.yaml) — Production staging
- [deploy-kong-PRD.yaml](.github/workflows/deploy-kong-PRD.yaml) — Production deployment

## Setup Guides

- [OrbStack Backend Setup](docs/orbstack-setup.md)
- [GitHub Actions Local Runner](docs/actions-runner-setup.md)

## Configuration

**Environment variables** (local):
- `.env` file for Docker Compose and local service configuration
- Copy from `.env.example` if provided

**Secrets** (GitHub Actions):
- `KONNECT_PAT` — Kong Konnect Personal Access Token for API access

**Terraform** (Konnect provisioning):
- `terraform.tfvars` (gitignored) with Konnect credentials and configuration

## More Information

- [Kong Documentation](https://docs.konghq.com/)
- [Kong Konnect](https://docs.konghq.com/konnect/)
- [Kong APIOps](https://github.com/Kong/go-apiops)
- [OpenAPI Specification](https://www.openapis.org/)
