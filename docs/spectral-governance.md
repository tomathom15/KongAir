# KongAir Spectral Governance Rules

This document describes the Spectral linting rules used to enforce API data governance in KongAir. These rules will catch the intentional inconsistencies present in Act 1 dark APIs and guide standardization in Act 2.

## Overview

The `.spectral.yaml` file in the root directory defines 13+ governance rules that enforce:

- **Consistent field naming** - camelCase, snake_case, PascalCase patterns
- **Timestamp format consistency** - ISO 8601 vs Unix epoch (not mixed)
- **Error response structure** - standardized error objects
- **Enum casing** - consistent case for enumerated values
- **Price/cost field naming** - single consistent field name
- **Data type consistency** - arrays vs strings for similar data
- **ID field naming patterns** - consistent ID field names
- **Status field naming** - consistent status/state field names

## Governance Rules

### 1. field-naming-consistency
**Severity**: warn  
**Description**: Field names should use consistent casing throughout the API  
**Detects**: Mix of camelCase and snake_case in property names

**Example violations**:
```yaml
# ❌ Violates: flightId (camelCase) vs flight_id (snake_case)
properties:
  flightId:
    type: string
  flight_id:
    type: string
```

### 2. timestamp-format-consistency
**Severity**: error  
**Description**: Timestamps must use consistent format across the API  
**Detects**: Mixed Unix epoch (integer) and ISO 8601 (date-time) formats

**Example violations in KongAir**:
- Seating: `createdAt: integer` (Unix) vs `lastUpdated: date-time` (ISO 8601)
- Operations: `actual_departure: integer` (Unix) vs `scheduled_departure: date-time` (ISO 8601)
- Ancillary: `preferences_updated_at: integer` (Unix) vs `confirmation_time: date-time` (ISO 8601)

### 3. price-field-consistency
**Severity**: error  
**Description**: Price-related fields must use consistent naming  
**Detects**: Mixing "price", "cost", and "pricing" in the same API

**Example violations in KongAir**:
```yaml
# ❌ Violates: price vs cost vs pricing
Ancillary service uses all three:
  - AddOns: price field
  - Meals: pricing field
  - Baggage: (implicit cost)
```

### 4. error-response-consistency
**Severity**: warn  
**Description**: All error responses should use the same structure  
**Detects**: Varying error object structures across endpoints

**Example violations in KongAir**:
```yaml
# ❌ Endpoint 1: Flat error with "code" and "description"
/bookings/{bookingId}/add-ons 404:
  code: "NOT_FOUND"
  description: "..."

# ❌ Endpoint 2: Nested error object
/routes/{routeId}/baggage-policy 404:
  error:
    status: 404
    message: "..."
    timestamp: "..."

# ❌ Endpoint 3: Simple message field
/flights/{flightId}/meals 404:
  msg: "..."
```

### 5. enum-casing-consistency
**Severity**: warn  
**Description**: Enum values should use consistent casing  
**Detects**: Mixed enum casing (kebab-case, UPPERCASE, lowercase)

**Example violations in KongAir**:
```yaml
# ❌ Violates: Mixed casing in status enum
status:
  enum: [on-time, DELAYED, cancelled]
  # on-time: kebab-case
  # DELAYED: UPPERCASE
  # cancelled: lowercase
```

### 6. dietary-array-consistency
**Severity**: error  
**Description**: Dietary preferences should always be arrays  
**Detects**: Mixing array format with comma-separated strings

**Example violations in KongAir**:
```yaml
# ❌ Seating meals: array format
dietary_options: [vegan, gluten-free, halal]

# ❌ Ancillary meals: comma-separated string
options: "vegan,vegetarian,standard"
```

### 7. id-field-naming
**Severity**: warn  
**Description**: ID fields should use consistent naming pattern  
**Detects**: Inconsistent ID field naming

**Example violations in KongAir**:
```yaml
# ❌ Violates: Inconsistent ID field naming
flightId:      # camelCase
flight_id:     # snake_case
bookingID:     # camelCase with capitals
booking_id:    # snake_case
```

### 8. status-field-naming
**Severity**: warn  
**Description**: Status fields should use consistent naming  
**Detects**: Inconsistent naming for status/state fields

**Example violations in KongAir**:
```yaml
# ❌ Violates: status vs operational_status
/flights/status endpoint:
  operational_status: "on-time"

/flights/crew endpoint:
  crew: null
  # No status field despite crew availability being status-like
```

### 9. timestamp-field-naming
**Severity**: warn  
**Description**: Timestamp fields should use consistent naming  
**Detects**: Varying names for timestamp fields

**Example violations in KongAir**:
```yaml
# ❌ Violates: Mixed timestamp field naming
createdAt:           # camelCase
last_updated:        # snake_case
updated_at:          # snake_case variant
confirmation_time:   # different purpose, different name
```

### 10. error-required-fields
**Severity**: error  
**Description**: All error responses must include standardized fields  
**Detects**: Missing required fields in error responses

**Example violations in KongAir**:
```yaml
# ❌ Missing required fields like message/error
invalid_request: true    # Just a boolean, no message
reason: "Missing fields" # Reason but no standard error field
```

### 11. http-status-code-type
**Severity**: warn  
**Description**: HTTP status codes should be integers, not strings  
**Detects**: Status code fields as strings instead of integers

**Example violations in KongAir**:
```yaml
# ❌ Violates: Status code as part of response payload
error:
  status: "404"    # Should be integer
```

### 12. pagination-field-consistency
**Severity**: warn  
**Description**: Pagination fields should use consistent naming  
**Detects**: Mixed pagination field names

**Example violations in KongAir**:
```yaml
# ❌ Violates: Mixed pagination naming
totalCount: 10      # camelCase
items: [...]        # Collection field name varies

# vs

totalCapacity: 180  # Different naming pattern
seatingChart: "..." # Different structure
```

## Running Spectral

### Installation

```bash
npm install -D @stoplight/spectral-cli
```

### Lint All OpenAPI Specs

```bash
# Lint all dark API specs
spectral lint docs/openapi/*.yaml

# Lint with specific ruleset
spectral lint -r .spectral.yaml docs/openapi/*.yaml
```

### Expected Violations

When you run Spectral against the KongAir dark API specs, you should see 20+ violations:

```
docs/openapi/seating-service.yaml
  28:14  warn     field-naming-consistency       Field naming inconsistency: flightId vs flight_id
  45:18  error    timestamp-format-consistency   Inconsistent timestamp formats detected
  
docs/openapi/operations-service.yaml
  52:16  warn     enum-casing-consistency        Enum status has mixed casing: on-time, DELAYED, cancelled
  
docs/openapi/ancillary-service.yaml
  84:12  error    price-field-consistency        Price field naming: price vs cost vs pricing
```

### CI/CD Integration

Add to `.github/workflows/api-lint.yml`:

```yaml
name: API Governance Linting

on: [push, pull_request]

jobs:
  spectral:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install -D @stoplight/spectral-cli
      - run: spectral lint -r .spectral.yaml docs/openapi/*.yaml
```

## Act 2: Fixing Violations

In Act 2, these Spectral violations will be resolved by:

1. **Standardizing timestamps**: All timestamps use ISO 8601 format
2. **Consistent field naming**: Choose snake_case or camelCase and apply consistently
3. **Error response structure**: All errors follow: `{error, message, timestamp}`
4. **Enum casing**: Status values use lowercase with hyphens: `on-time`, `delayed`, `cancelled`
5. **Price field**: Single `price` field instead of `cost`/`pricing` variants
6. **Data types**: Dietary options always array, never comma-separated
7. **Field naming**: Consistent patterns for ids, status, timestamps, pagination

## References

- [Spectral Documentation](https://meta.stoplight.io/docs/spectral)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.3)
- [API Design Best Practices](https://swagger.io/resources/articles/best-practices-in-api-design/)
