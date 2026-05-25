# Kong Services for Act 2 — Full Documentation with Governance
# All services configured with complete path documentation
# Dark APIs from Act 1 are now explicitly documented

# Flights Service
resource "konnect_gateway_service" "flights" {
  name     = "flights-service"
  host     = "flights.kongair"
  port     = 5052
  protocol = "http"

  tags = ["act2", "documented", "governed", "flight-data"]
}

# Routes Service
resource "konnect_gateway_service" "routes" {
  name     = "routes-service"
  host     = "routes.kongair"
  port     = 5053
  protocol = "http"

  tags = ["act2", "documented", "governed", "flight-data"]
}

# Customers Service
resource "konnect_gateway_service" "customers" {
  name     = "customers-service"
  host     = "customers.kongair"
  port     = 5051
  protocol = "http"

  tags = ["act2", "documented", "governed", "sales"]
}

# Bookings Service
resource "konnect_gateway_service" "bookings" {
  name     = "bookings-service"
  host     = "bookings.kongair"
  port     = 5054
  protocol = "http"

  tags = ["act2", "documented", "governed", "sales"]
}

# Seating Service
resource "konnect_gateway_service" "seating" {
  name     = "seating-service"
  host     = "seating.kongair"
  port     = 5055
  protocol = "http"

  tags = ["act2", "documented", "governed", "seating"]
}

# Operations Service
resource "konnect_gateway_service" "operations" {
  name     = "operations-service"
  host     = "operations.kongair"
  port     = 5056
  protocol = "http"

  tags = ["act2", "documented", "governed", "operations"]
}

# Ancillary Service
resource "konnect_gateway_service" "ancillary" {
  name     = "ancillary-service"
  host     = "ancillary.kongair"
  port     = 5057
  protocol = "http"

  tags = ["act2", "documented", "governed", "ancillary"]
}

# Experience Service
resource "konnect_gateway_service" "experience" {
  name     = "experience-service"
  host     = "experience.kongair"
  port     = 5050
  protocol = "http"

  tags = ["act2", "documented", "governed", "experience"]
}

# Service ID outputs for use in routes
output "flights_service_id" {
  value = konnect_gateway_service.flights.id
}

output "routes_service_id" {
  value = konnect_gateway_service.routes.id
}

output "customers_service_id" {
  value = konnect_gateway_service.customers.id
}

output "bookings_service_id" {
  value = konnect_gateway_service.bookings.id
}

output "seating_service_id" {
  value = konnect_gateway_service.seating.id
}

output "operations_service_id" {
  value = konnect_gateway_service.operations.id
}

output "ancillary_service_id" {
  value = konnect_gateway_service.ancillary.id
}

output "experience_service_id" {
  value = konnect_gateway_service.experience.id
}
