# KongAir Terraform Configuration

This folder contains Terraform configurations for Kong API Gateway across two regions, aligned with the APIOps demo's Act 1 and Act 2.

## Structure

```
terraform/
├── konnect-us/        # Act 1: US Region — Base Paths Only
│   ├── main.tf        # Provider configuration
│   ├── services.tf    # Service definitions
│   └── routes.tf      # Route definitions (base paths)
│
├── konnect-au/        # Act 2: AU Region — Full Documentation + Governance
│   ├── main.tf        # Provider configuration
│   ├── services.tf    # Service definitions
│   └── routes.tf      # Route definitions (documented + dark APIs)
│
└── archive/           # Legacy configurations (not in use)
    └── *.tf          # Previous control plane and infrastructure files
```

## Regions

### konnect-us: Act 1 — Base Paths Only

**Purpose**: Demonstrates the problem—dark APIs hidden from governance.

**Configuration**:
- All services configured with base paths only
- Only documented endpoints exposed through Kong:
  - `/flights`
  - `/routes`
  - `/customers`
  - `/bookings`
  - `/seating`
  - `/operations`
  - `/ancillary`
  - `/experience`
- All sub-paths and undocumented endpoints remain invisible
- Traffic injector shows ~100% failures on unconfigured gateway (no governance)

**Deploy with**:
```bash
cd konnect-us
terraform init
terraform apply
```

### konnect-au: Act 2 — Full Documentation + Governance

**Purpose**: Demonstrates the solution—all APIs documented with governance.

**Configuration**:
- All services fully documented with explicit route definitions
- Documented base paths + previously dark API endpoints now exposed:
  - **Flights**: `/flights`, `/flights/search`, `/flights/history/*`, `/flights/*/seats`
  - **Seating**: `/seating`, `/seating/flights/*/seatingMap`, `/seating/flights/*/seats`
  - **Operations**: `/operations`, `/operations/flights/*/status`, `/operations/flights/*/crew`, `/operations/flights/*/gate`
  - **Ancillary**: `/ancillary`, `/ancillary/bookings/*/add-ons`, `/ancillary/routes/*/baggage-policy`, `/ancillary/flights/*/meals`, `/ancillary/customer/*/meal-preferences`
  - Plus documented: `/routes`, `/customers`, `/bookings`, `/experience`
- All endpoints tagged with `discovered-dark-api` for easy identification
- Ready for governance policies (rate limiting, authentication, request validation)

**Deploy with**:
```bash
cd konnect-au
terraform init
terraform apply
```

## Demo Workflow

### Before Demo
1. Deploy US region (Act 1 base configuration)
2. Deploy AU region pre-staged (Act 2 full configuration)

### During Act 1 (The Problem)
- Traffic targets US region (basic paths, no governance)
- Traffic injector shows ~100% failures (no routing configured)
- Demonstrates undiscovered dark APIs

### During Act 2 (The Solution)
- Switch traffic to AU region (full documentation, governance ready)
- Apply governance policies (rate limiting, auth, etc.)
- Show how standards enforcement prevents API sprawl

## Tagging Strategy

All resources are tagged for easy identification:

- **act1** / **act2**: Identifies which demo phase
- **documented** / **discovered-dark-api**: API visibility status
- **governed**: Governance policies applied (Act 2 only)
- **{service-name}**: Service domain (flight-data, sales, seating, operations, ancillary, experience)

## Notes

- Services point to `.kongair` host names (e.g., `flights.kongair:5052`)
- In OrbStack, these resolve via docker-compose network bridge
- Port mapping:
  - Experience: 5050
  - Customers: 5051
  - Flights: 5052
  - Routes: 5053
  - Bookings: 5054
  - Seating: 5055
  - Operations: 5056
  - Ancillary: 5057

## Legacy Archive

The `archive/` folder contains previous control plane and infrastructure configurations that are no longer in use. These were replaced with the simpler service-and-route approach aligned to the demo narrative.
