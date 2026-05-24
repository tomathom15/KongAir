# Traffic Injector

Generates realistic KongAir airline usage patterns to make the demo APIs appear "live" with actual traffic flowing through Kong.

## Purpose

During the Act 1 live demo, this injector pushes realistic traffic patterns:
- Flight searches
- Booking flows
- Customer account lookups
- Seat map queries

This makes the "dark APIs" (undocumented endpoints) visible in Kong's traffic logs and analytics, even though they're not documented in the OpenAPI specs.

## Target Metrics

- **Throughput**: 10–20 TPS (transactions per second)
- **Pattern**: Realistic airline workflows (search → book → check status)
- **Endpoints**: Mix across flights, bookings, customers, routes
- **Burst**: Optional traffic spikes for analytics visibility

## Configuration

TBD — will implement with configurable:
- Target gateway URL (local Kong or Konnect)
- Request rate (TPS)
- Endpoint weights
- Duration

## Running

```bash
# TBD
```

## Implementation

To be built using one of:
- Go (fast, minimal dependencies)
- Python (quick to write)
- JavaScript/Node (easy to configure)

Will generate requests to both documented and dark API endpoints.
