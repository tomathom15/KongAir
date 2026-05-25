# Kong Routes for Act 1 — Base Paths Only
# Only documented base paths are exposed through Kong gateway
# All sub-paths and undocumented endpoints remain invisible (dark APIs)

# Flights Service Route
resource "konnect_gateway_route" "flights" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "flights-route"
  paths = [
    "/flights"
  ]

  service = {
    id = konnect_gateway_service.flights.id
  }

  tags = ["act1", "documented", "flight-data"]
}

# Routes Service Route
resource "konnect_gateway_route" "routes" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "routes-route"
  paths = [
    "/routes"
  ]

  service = {
    id = konnect_gateway_service.routes.id
  }

  tags = ["act1", "documented", "flight-data"]
}

# Customers Service Route
resource "konnect_gateway_route" "customers" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "customers-route"
  paths = [
    "/customers"
  ]

  service = {
    id = konnect_gateway_service.customers.id
  }

  tags = ["act1", "documented", "sales"]
}

# Bookings Service Route
resource "konnect_gateway_route" "bookings" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "bookings-route"
  paths = [
    "/bookings"
  ]

  service = {
    id = konnect_gateway_service.bookings.id
  }

  tags = ["act1", "documented", "sales"]
}

# Seating Service Route
resource "konnect_gateway_route" "seating" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "seating-route"
  paths = [
    "/seating"
  ]

  service = {
    id = konnect_gateway_service.seating.id
  }

  tags = ["act1", "documented", "seating"]
}

# Operations Service Route
resource "konnect_gateway_route" "operations" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "operations-route"
  paths = [
    "/operations"
  ]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act1", "documented", "operations"]
}

# Ancillary Service Route
resource "konnect_gateway_route" "ancillary" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "ancillary-route"
  paths = [
    "/ancillary"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act1", "documented", "ancillary"]
}

# Experience Service Route
resource "konnect_gateway_route" "experience" {
  control_plane_id = data.konnect_gateway_control_plane.act1.id
  name             = "experience-route"
  paths = [
    "/experience"
  ]

  service = {
    id = konnect_gateway_service.experience.id
  }

  tags = ["act1", "documented", "experience"]
}

# Route ID outputs for verification
output "flights_route_id" {
  value = konnect_gateway_route.flights.id
}

output "routes_route_id" {
  value = konnect_gateway_route.routes.id
}

output "customers_route_id" {
  value = konnect_gateway_route.customers.id
}

output "bookings_route_id" {
  value = konnect_gateway_route.bookings.id
}

output "seating_route_id" {
  value = konnect_gateway_route.seating.id
}

output "operations_route_id" {
  value = konnect_gateway_route.operations.id
}

output "ancillary_route_id" {
  value = konnect_gateway_route.ancillary.id
}

output "experience_route_id" {
  value = konnect_gateway_route.experience.id
}
