# KongAir Demo Walkthrough

This guide walks through the KongAir API governance demonstration, showing the problem (Act 1) and the solution (Act 2).

## Demo Overview

**Act 1: The Problem** shows how API governance is lacking:
- Dark APIs: undocumented endpoints that aren't in any catalog
- Inconsistent response formats and error handling
- No service contracts or API specifications
- Difficult to discover, maintain, and monitor

**Act 2: The Solution** demonstrates how Kong and API governance fix this:
- APIs documented with OpenAPI specifications
- Service contracts enforced through Kong Konnect
- Governance rules applied at the gateway level
- Improved discoverability, monitoring, and compliance

## Prerequisites

Before running the demo, ensure you have:

- **OrbStack** or **Docker Desktop** installed and running
- **Git** installed and configured
- **Insomnia** or similar API client (free tier is fine)
- **Kong account** with Konnect access (free tier available)
- The KongAir repository cloned locally

## Part 1: Understanding the Architecture

### The KongAir System

KongAir is an airline booking platform with these core services:

- **Experience Service**: User interface and customer experience (port 5050)
- **Customers Service**: Customer profile and preferences (port 5051)
- **Flights Service**: Flight information and search (port 5052)
- **Routes Service**: Route definitions and pricing (port 5053)
- **Bookings Service**: Booking management (port 5054)
- **Seating Service**: Aircraft seating and assignment (port 5055)
- **Operations Service**: Flight status, crew, gates (port 5056)
- **Ancillary Service**: Add-ons, meals, baggage policies (port 5057)
- **Kong Gateway**: API Gateway and governance layer (port 8000 proxy, 8001 admin)
- **Traffic Injector**: Generates realistic load during demo (background service)

### Network Architecture

All services run in a Docker bridge network (`kongair-net`) for internal communication:

```
External Client
    ↓
Kong Gateway (Port 8000 - Proxy)
    ↓ (routes requests based on path and service)
Internal Services:
  - Seating Service
  - Operations Service
  - Ancillary Service
  - (Other services available directly)
```

Kong Gateway:
- Acts as the API gateway and reverse proxy
- Routes requests to appropriate backend services
- Enforces governance policies
- Connected to Kong Konnect for centralized management

## Part 2: Running Act 1 - The Problem

### Step 1: Start the Demo

```bash
cd /path/to/KongAir
chmod +x demo_instructions/*.sh
./demo_instructions/start-demo-act1.sh
```

This script will:
1. Check that you're on the `main` branch
2. Start all backend services
3. Start Kong Gateway (connected to Konnect)
4. Start the traffic injector generating realistic API calls
5. Wait for Kong to be ready

You should see output indicating all services are running.

### Step 2: Verify Services Are Running

In a new terminal, verify services are accessible:

```bash
# Test Kong Gateway
curl http://localhost:8000/

# Check Kong Admin API
curl http://localhost:8001/services

# Test a direct backend service
curl http://localhost:5052/flights
```

### Step 3: Observe the Dark APIs

The dark APIs are undocumented endpoints that live in the system but aren't properly cataloged:

#### Seating Service Dark APIs
These endpoints aren't in any documentation:

```bash
# Get seating map for a flight (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/seatingMap" \
  -H "Content-Type: application/json"

# Get available seats (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/seats" \
  -H "Content-Type: application/json"
```

#### Operations Service Dark APIs

```bash
# Get flight status (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/status" \
  -H "Content-Type: application/json"

# Get crew information (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/crew" \
  -H "Content-Type: application/json"

# Get gate information (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/gate" \
  -H "Content-Type: application/json"
```

#### Ancillary Service Dark APIs

```bash
# Get add-ons for a booking (undocumented)
curl -X GET "http://localhost:8000/bookings/BK001/add-ons" \
  -H "Content-Type: application/json"

# Add add-ons to booking (undocumented)
curl -X POST "http://localhost:8000/bookings/BK001/add-ons" \
  -H "Content-Type: application/json" \
  -d '{"addOn": "extra-baggage"}'

# Get baggage policy (undocumented)
curl -X GET "http://localhost:8000/routes/US-EU/baggage-policy" \
  -H "Content-Type: application/json"

# Get meal options (undocumented)
curl -X GET "http://localhost:8000/flights/AA100/meals" \
  -H "Content-Type: application/json"

# Get customer meal preferences (undocumented)
curl -X GET "http://localhost:8000/customer/CUST001/meal-preferences" \
  -H "Content-Type: application/json"
```

### Step 4: Inspect Kong Configuration (or lack thereof)

Check what Kong knows about these services:

```bash
# List services registered in Kong
curl http://localhost:8001/services | jq '.'

# Notice: The services aren't properly registered!
# Kong only knows about the direct backend services,
# not the organized API paths and governance
```

### Step 5: Discuss the Problems

Notice these issues in Act 1:

1. **Discoverability**: How would a new developer find these endpoints?
2. **Documentation**: No OpenAPI specs, no request/response schemas
3. **Consistency**: Different services use different response formats
4. **Governance**: No rate limiting, no authentication, no validation
5. **Monitoring**: Hard to track which APIs are used and how
6. **Contracts**: No service level agreements or documented expectations
7. **Security**: No proper API authentication or authorization

## Part 3: Running Act 2 - The Solution

### Step 1: Switch to Act 2

```bash
./demo_instructions/start-demo-act2.sh
```

This script will:
1. Stop Act 1 services
2. Switch to the `act2-standardized-services` branch
3. Start all services again with standardized configurations
4. Configure Kong with proper service definitions
5. Apply governance policies

### Step 2: Verify Improvements

The same API calls from Act 1 still work, but now they're properly governed:

```bash
# Same endpoint, but now it's governed
curl -X GET "http://localhost:8000/flights/AA100/seatingMap" \
  -H "Content-Type: application/json"
```

### Step 3: Check Kong Configuration

Now Kong knows about the services:

```bash
# List services - properly configured!
curl http://localhost:8001/services | jq '.'

# List routes with proper path definitions
curl http://localhost:8001/routes | jq '.'

# Check installed plugins for governance
curl http://localhost:8001/plugins | jq '.'
```

### Step 4: Review Governance Policies

In Act 2, governance is enforced:

#### Rate Limiting
```bash
# Seating Service: 100 requests per minute per customer
# Try making multiple requests quickly to see rate limiting in action

for i in {1..105}; do
  curl -X GET "http://localhost:8000/flights/AA100/seatingMap" \
    -H "Content-Type: application/json" \
    -H "X-Customer-ID: CUST001"
  echo "Request $i"
done
```

After 100 requests, you'll see rate limit errors.

#### Authentication
```bash
# Operations Service requires authentication
# Without token, request fails
curl -X GET "http://localhost:8000/flights/AA100/status" \
  -H "Content-Type: application/json"

# Error: 401 Unauthorized

# With proper authentication, it works
curl -X GET "http://localhost:8000/flights/AA100/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Request Validation
```bash
# Ancillary Service validates request schema
# Invalid payload gets rejected

curl -X POST "http://localhost:8000/bookings/BK001/add-ons" \
  -H "Content-Type: application/json" \
  -d '{"invalid": "format"}'

# Error: 400 Bad Request - Schema validation failed
```

### Step 5: Review API Documentation

In Act 2, all APIs are documented:

```bash
# Get OpenAPI specification for seating service
curl http://localhost:8001/services/seating-service | jq '.openapi_spec'

# View service metadata
curl http://localhost:8001/services/seating-service | jq '.'
```

## Part 4: Discussing the Benefits

Act 2 demonstrates these improvements:

1. **Clear Documentation**: All APIs have OpenAPI specs
2. **Discoverability**: Developers can browse available endpoints in Kong Konnect
3. **Consistency**: All services follow the same request/response patterns
4. **Governance**: Rate limiting, authentication, validation enforced
5. **Monitoring**: Kong tracks usage, latency, and error rates
6. **Contracts**: Service level agreements are defined and enforced
7. **Security**: Proper authentication and authorization in place
8. **Maintenance**: Changes to APIs are tracked and versioned

## Part 5: Switching Between Acts

### Switch from Act 1 to Act 2
```bash
./demo_instructions/start-demo-act2.sh
```

### Switch from Act 2 to Act 1
```bash
./demo_instructions/start-demo-act1.sh
```

### Stop the Demo
```bash
./demo_instructions/stop-demo.sh
```

## Key Takeaways

**The Problem (Act 1):**
- Undocumented APIs hide critical business logic
- No governance makes systems hard to maintain
- Inconsistency causes integration issues
- Lack of monitoring makes troubleshooting difficult

**The Solution (Act 2):**
- Kong as the API gateway enforces governance
- OpenAPI specs make APIs discoverable and maintainable
- Konnect provides centralized API catalog and management
- Governance policies ensure reliability and security

## Troubleshooting

### Services won't start
```bash
# Check Docker is running
docker ps

# Check logs
docker-compose -f docker-compose-orbstack.yaml logs

# Force restart
docker-compose -f docker-compose-orbstack.yaml down
docker-compose -f docker-compose-orbstack.yaml up -d
```

### Kong not responding
```bash
# Check Kong container
docker ps | grep kong

# Check Kong logs
docker-compose -f docker-compose-orbstack.yaml logs kong

# Wait longer (Kong can take time to start)
sleep 10
curl http://localhost:8001
```

### Port conflicts
```bash
# Check if ports are in use
lsof -i :8000
lsof -i :8001

# Stop KongAir and try again
./demo_instructions/stop-demo.sh
./demo_instructions/start-demo-act1.sh
```

## Learning Resources

- **Kong Documentation**: https://docs.konghq.com/
- **Konnect Docs**: https://docs.konghq.com/konnect/
- **OpenAPI Specification**: https://www.openapis.org/
- **API Governance**: https://www.konghq.com/blog/
