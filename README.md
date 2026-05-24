# KongAir — APIOps Demo for Helsinki

This repository is the demo environment for **APIOps Meetup Helsinki** — a live presentation on API Governance and the journey from discovering "dark APIs" to enforcing platform standards.

## The Two-Act Demo

### Act 1: The Dark
APIs exist and are running, but nobody knows what's really there. This act showcases the **discovery problem**:
- Undocumented API endpoints in production (dark APIs)
- Unknown traffic patterns and usage
- No governance, no contracts, no visibility

The APIOps pipeline is used live to discover and document these dark APIs via Insomnia → automated testing → deployment to Kong.

### Act 2: The Light
The same APIs, now properly governed:
- Specs documented and published in Dev Portal
- Standards enforced via Spectral linting
- Contract and security testing built into the pipeline
- Traffic visible and managed in Kong analytics

## Architecture

- **Two Konnect regions**: US (Act 1 — live demo), AU (Act 2 — pre-staged governance)
- **Local backends**: KongAir services running via Docker Compose on OrbStack
- **GitHub Actions pipeline**: Running on a local self-hosted runner inside OrbStack
- **Traffic injector**: Generates realistic airline usage patterns (10–20 TPS)

## Quick Start (OrbStack)

### Start the backends
```bash
docker-compose -f docker-compose-orbstack.yaml up -d
```

This starts all KongAir services (flights, routes, bookings, customers, experience) locally.

### Stop everything
```bash
docker-compose -f docker-compose-orbstack.yaml down
```

Or use the included script:
```bash
./kill-all.sh
```

## Repository Structure

```
tomathom15/KongAir
├── flight-data/          # Flights and routes APIs (with dark endpoints in Act 1)
├── sales/                # Bookings and customer services
├── experience/           # GraphQL aggregation layer
├── platform/             # Kong/Konnect governance configs
├── PRD/kong/             # Production Kong configs
├── tf/                   # Terraform for Konnect provisioning (US + AU regions)
├── .github/workflows/    # APIOps CI/CD pipelines
├── cfg/portal/           # Dev Portal config (Act 2)
├── traffic-injector/     # Realistic traffic generator for demo
├── scripts/              # Deployment and sync utilities
├── docs/                 # OrbStack and Actions runner setup guides
├── docker-compose.yaml   # Standard setup
└── docker-compose-orbstack.yaml  # OrbStack-optimized (ARM64)
```

## APIOps Pipeline (Act 1)

The centerpiece of Act 1 is a GitHub Actions workflow that demonstrates end-to-end APIOps:

1. **OAS Spec Change** (Insomnia) → PR in GitHub
2. **Breaking Change Detection** → GitHub Issue
3. **Contract Testing** (Schemathesis) → Verify API contracts
4. **Security Testing** (OWASP ZAP) → API security scan
5. **Load Testing** (K6) → Performance baseline
6. **OAS → Kong Config** (go-apiops) → Generate Kong configuration
7. **Deploy to Konnect** (deck) → Live in Kong

Key workflows:
- [stage-changes-for-kong.yaml](.github/workflows/stage-changes-for-kong.yaml) — Full APIOps pipeline
- [apply-terraform.yaml](.github/workflows/apply-terraform.yaml) — Konnect provisioning
- [deploy-kong-PRD.yaml](.github/workflows/deploy-kong-PRD.yaml) — Production sync

## Demo Extensions

### Traffic Injector
Generates realistic KongAir usage patterns — search flights, book, check status — at 10–20 TPS. Makes metrics and analytics in Konnect come alive during the demo.

### Dark API Endpoints
Undocumented sub-paths added to the KongAir services:
- `/flights/search` — Flight search without booking
- `/flights/details` — Single flight details
- `/flights/history` — User's flight history
- Similar dark endpoints on `/bookings`, `/customers`

These exist in the backends but are **not documented in OAS specs** and **not configured in Kong** — the discovery problem Act 1 solves.

### Spectral Rules
Static copies of API design rules in each OAS directory. Insomnia loads them locally, demonstrating live enforcement as specs are edited.

## Setup Guides

- [OrbStack Backend Setup](docs/orbstack-setup.md)
- [GitHub Actions Local Runner](docs/actions-runner-setup.md)

## Secrets

**Never commit secrets.** Use:
- `.env` file (gitignored) for local use
- GitHub Actions Secrets for workflows: `KONNECT_PAT`
- Terraform variables: `terraform.tfvars` (gitignored)

The KONNECT_PAT is managed separately and not stored in the repo.

## More Information

- [Kong APIOps](https://github.com/Kong/go-apiops)
- [Kong Konnect Developer Portal](https://docs.konghq.com/konnect/)
- [Spectral OpenAPI Linting](https://www.stoplight.io/open-source/spectral)
- [Schemathesis API Testing](https://schemathesis.io/)
