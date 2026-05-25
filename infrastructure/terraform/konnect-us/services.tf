# Kong Services for Act 1 — Base Paths Only
# All services are configured with base paths for documented APIs only
# Dark APIs (undocumented sub-paths) remain invisible

# Flights Service
resource "konnect_gateway_service" "flights" {
  control_plane_id = var.control_plane_id
  name             = "flights-service"
  host             = "kongair-flights.kongair.orb.local"
  port             = 5052
  protocol         = "http"

  tags = ["act1", "documented", "flight-data"]
}

# Routes Service
resource "konnect_gateway_service" "routes" {
  control_plane_id = var.control_plane_id
  name             = "routes-service"
  host             = "kongair-routes.kongair.orb.local"
  port             = 5053
  protocol         = "http"

  tags = ["act1", "documented", "flight-data"]
}

# Customers Service
resource "konnect_gateway_service" "customers" {
  control_plane_id = var.control_plane_id
  name             = "customers-service"
  host             = "kongair-customers.kongair.orb.local"
  port             = 5051
  protocol         = "http"

  tags = ["act1", "documented", "sales"]
}

# Bookings Service
resource "konnect_gateway_service" "bookings" {
  control_plane_id = var.control_plane_id
  name             = "bookings-service"
  host             = "kongair-bookings.kongair.orb.local"
  port             = 5054
  protocol         = "http"

  tags = ["act1", "documented", "sales"]
}

# Seating Service
resource "konnect_gateway_service" "seating" {
  control_plane_id = var.control_plane_id
  name             = "seating-service"
  host             = "kongair-seating.kongair.orb.local"
  port             = 5055
  protocol         = "http"

  tags = ["act1", "documented", "seating"]
}

# Operations Service
resource "konnect_gateway_service" "operations" {
  control_plane_id = var.control_plane_id
  name             = "operations-service"
  host             = "kongair-operations.kongair.orb.local"
  port             = 5056
  protocol         = "http"

  tags = ["act1", "documented", "operations"]
}

# Ancillary Service
resource "konnect_gateway_service" "ancillary" {
  control_plane_id = var.control_plane_id
  name             = "ancillary-service"
  host             = "kongair-ancillary.kongair.orb.local"
  port             = 5057
  protocol         = "http"

  tags = ["act1", "documented", "ancillary"]
}

# Experience Service
resource "konnect_gateway_service" "experience" {
  control_plane_id = var.control_plane_id
  name             = "experience-service"
  host             = "kongair-experience.kongair.orb.local"
  port             = 5050
  protocol         = "http"

  tags = ["act1", "documented", "experience"]
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
