# KongAir API Governance - Act 1 & Act 2

This document provides an overview of the API governance story demonstrated in the KongAir APIOps demo for the Helsinki conference.

## The Problem: Act 1 - Dark APIs & Inconsistency

In Act 1, we discover and expose the **dark APIs** - undocumented endpoints that grew organically across three new backend services:

### Three Dark API Services

1. **Seating Service** (port 5055)
   - Manages flight seating maps and seat availability
   - Endpoints: `/flights/{flightId}/seatingMap`, `/flights/{flightId}/seats`, etc.

2. **Operations Service** (port 5056)
   - Flight status, crew information, gate assignments
   - Endpoints: `/flights/{flightNum}/status`, `/flights/{flightNum}/crew`, `/flights/{flightNum}/gate`

3. **Ancillary Service** (port 5057)
   - Booking add-ons, baggage policies, meal options
   - Endpoints: `/bookings/{bookingId}/add-ons`, `/routes/{routeId}/baggage-policy`, `/flights/{flightId}/meals`

### The Inconsistencies

Each service evolved independently, resulting in significant data governance challenges:

#### Field Naming
- **Problem**: flightId (camelCase) vs flight_id (snake_case) - even within the same response
- **Impact**: Client code must handle multiple naming patterns; hard to build consistent client SDKs

#### Timestamp Formats
- **Problem**: Unix epoch (milliseconds) vs ISO 8601 - sometimes both in the same response
- **Impact**: Inconsistent parsing logic; timezone handling errors; date math errors

#### Error Response Structure
```
# Seating Service
{
  "error": "Flight not found",
  "code": "FLIGHT_NOT_FOUND"
}

# Operations Service
{
  "error_code": 404,
  "error_message": "No data for KA0924"
}

# Ancillary Service
{
  "msg": "No meals available for flight KA0924"
}
```
- **Impact**: Client error handling code must know about 3+ error formats

#### Price Field Naming
- Ancillary service uses: `price`, `cost`, and `pricing` for essentially the same concept
- **Impact**: Ambiguity about which field to use; client confusion

#### Enumeration Casing
- Status values: `"on-time"` (kebab-case), `"DELAYED"` (UPPERCASE), `"cancelled"` (lowercase)
- **Impact**: Client switch/case statements break; validation inconsistent

#### Data Type Inconsistency
- Dietary options: sometimes array `[vegan, gluten-free]`, sometimes string `"vegan,vegetarian,standard"`
- **Impact**: Parsing logic differs; bugs when API changes format

## The Solution: Act 2 - Governance Enforcement

Act 2 demonstrates how Kong, OpenAPI specifications, and Spectral linting enforce governance standards across these dark APIs.

### Step 1: Document the Current State

**Files**: `docs/openapi/*.yaml`
- Seating Service spec: documents all inconsistencies as they exist
- Operations Service spec: captures mixed timestamp formats, error structures
- Ancillary Service spec: shows field naming variations, data type inconsistencies

All inconsistencies are clearly marked in the specs:
```yaml
properties:
  flightID:
    type: string
    description: Note inconsistent casing (flightID vs flightId)
```

### Step 2: Define Governance Rules

**File**: `.spectral.yaml`

13+ linting rules enforce:
1. Consistent field naming (choose camelCase OR snake_case, not both)
2. Timestamp format (choose ISO 8601 OR Unix epoch, not mixed)
3. Error response structure (standardized error object)
4. Enum value casing (choose lowercase-with-hyphens consistently)
5. Price field naming (single `price` field, not cost/pricing variants)
6. Dietary options (always array, never comma-separated string)
7. And 7 more governance rules...

### Step 3: Detect Violations

Run Spectral against the dark API specs:
```bash
npm run lint:api
```

This detects 20+ governance violations:
```
docs/openapi/seating-service.yaml
  28:14  warn     field-naming-consistency       Mixed casing: flightId vs flight_id
  45:18  error    timestamp-format-consistency   Unix vs ISO 8601 mixed
  
docs/openapi/operations-service.yaml  
  52:16  error    enum-casing-consistency        on-time vs DELAYED vs cancelled
  
docs/openapi/ancillary-service.yaml
  84:12  error    price-field-consistency        price vs cost vs pricing
  125:8  error    dietary-array-consistency      array vs comma-separated string
```

### Step 4: Enforce Standards

In Act 2 Kong configuration (Konnect AU region):

#### Service Transformations
```bash
# Seating Service: Convert all timestamps to ISO 8601
kong plugin add response-transformer \
  --config tokens.created_at="var.now_iso8601"

# Operations Service: Standardize status enum
kong plugin add request-transformer \
  --config replace.status_lower="tolower(status)"

# Ancillary Service: Unify price fields
kong plugin add response-transformer \
  --config add.price="coalesce(price, cost, pricing)"
```

#### Standardized Error Response
```yaml
error_handler:
  type: object
  required: [error, message, timestamp]
  properties:
    error:
      type: string
    message:
      type: string
    timestamp:
      type: string
      format: date-time
```

## Demo Flow

### Act 1: Chaos
1. Run traffic injector against dark APIs
   ```bash
   npm run traffic-injector
   ```
   - Shows 400+ requests to inconsistent endpoints
   - Clients must handle 3+ error formats
   - Response field naming varies

2. **Point**: "These dark APIs work, but they're a nightmare for client developers"

### Act 2: Governance
1. Run Spectral linting
   ```bash
   npm run lint:api
   ```
   - Shows 20+ governance violations
   - **Point**: "We can automatically detect these problems"

2. Apply Kong service transformations
   - **Point**: "Kong enforces governance at runtime"

3. Run traffic injector again
   - Shows consistent responses across all services
   - Standardized error handling
   - Unified field naming
   - **Point**: "Clients now have a single, consistent API contract"

## Key Files

### OpenAPI Specifications
- `docs/openapi/seating-service.yaml` - Seating API with inconsistencies documented
- `docs/openapi/operations-service.yaml` - Operations API with mixed enums and timestamps
- `docs/openapi/ancillary-service.yaml` - Ancillary API with field naming variations

### Governance Rules
- `.spectral.yaml` - 13+ linting rules for enforcement
- `docs/spectral-governance.md` - Detailed rule documentation with examples

### Supporting Files
- `package.json` - Scripts for linting and traffic injection
- `traffic-injector/main.go` - Generates traffic to dark APIs
- `docker-compose-orbstack.yaml` - Local containerized deployment

## Running the Demo Locally

```bash
# 1. Start all services
docker-compose -f docker-compose-orbstack.yaml up

# 2. Check API documentation (Act 1)
cat docs/openapi/seating-service.yaml

# 3. Run governance linting (Act 2)
npm install
npm run lint:api

# 4. Generate realistic traffic
npm run traffic-injector
```

## Governance Checklist

### Act 1 ✅
- [x] Three dark API services created with intentional inconsistencies
- [x] OpenAPI specifications document existing state (with inconsistencies)
- [x] Spectral rules defined to detect violations
- [x] Traffic injector shows client challenges with inconsistency

### Act 2 (To Do)
- [ ] Kong services configured with base path routing
- [ ] Service transformation plugins apply governance
- [ ] Standardized error response structure enforced
- [ ] Timestamps normalized to ISO 8601
- [ ] Enum values standardized to lowercase-with-hyphens
- [ ] Price fields unified
- [ ] Spectral violations resolved to 0
- [ ] Demo shows before/after traffic patterns

## References

- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)
- [Spectral Documentation](https://meta.stoplight.io/docs/spectral)
- [Kong Service Transformations](https://docs.konghq.com/hub/kong-inc/response-transformer/)
- [API Design Best Practices](https://swagger.io/resources/articles/best-practices-in-api-design/)
