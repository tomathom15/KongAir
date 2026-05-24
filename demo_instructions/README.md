# KongAir Demo Instructions

This folder contains scripts and documentation to run through the KongAir API governance demonstration.

## Folder Structure

- **start-demo-act1.sh** - Initialize Act 1 environment (inconsistent, undocumented dark APIs)
- **start-demo-act2.sh** - Initialize Act 2 environment (standardized, governed APIs)
- **stop-demo.sh** - Clean up running services
- **demo-walkthrough.md** - Step-by-step manual walkthrough guide

## Quick Start

### Prerequisites
- OrbStack installed and running
- Docker Compose available
- Kong and Konnect accounts configured
- Insomnia or similar API client

### Run Act 1 Demo
```bash
./start-demo-act1.sh
```

This will:
1. Start all backend services (customers, flights, routes, bookings, seating, operations, ancillary)
2. Start Kong Gateway connected to Konnect
3. Start the traffic injector generating realistic load
4. Output instructions for loading the Act 1 Insomnia collection

### Switch to Act 2 Demo
```bash
./start-demo-act2.sh
```

This will:
1. Switch to the act2-standardized-services branch
2. Restart services with standardized, governed APIs
3. Load Act 2 Insomnia collection configuration
4. Display governance rules and service contracts

### Stop Demo
```bash
./stop-demo.sh
```

Cleans up all running containers and services.

## Demo Narrative

**Act 1: The Problem**
- Dark APIs: undocumented endpoints hiding business logic
- Inconsistent response formats and error handling
- No governance or API contracts
- Difficult to maintain and monitor

**Act 2: The Solution**
- Standardized API contracts with OpenAPI specs
- Documented endpoints in Kong Konnect
- Governance rules enforced by Kong Gateway
- Improved monitoring and compliance
