# Kong Routes for Act 2 — Full Documentation with Governance
# All documented APIs and discovered dark APIs are now explicitly exposed
# Each endpoint is documented and can have governance policies applied

# ============================================================================
# Flights Service Routes
# ============================================================================

# Documented base path
resource "konnect_gateway_route" "flights_base" {
  name = "flights-base-route"
  paths = [
    "/flights"
  ]

  service = {
    id = konnect_gateway_service.flights.id
  }

  tags = ["act2", "documented", "governed", "flight-data"]
}

# Dark API: Alternative search endpoint
resource "konnect_gateway_route" "flights_search" {
  name = "flights-search-route"
  paths = [
    "/flights/search"
  ]

  service = {
    id = konnect_gateway_service.flights.id
  }

  tags = ["act2", "documented", "governed", "flight-data", "discovered-dark-api"]
}

# Dark API: Flight history by customer
resource "konnect_gateway_route" "flights_history" {
  name = "flights-history-route"
  paths = [
    "/flights/history/*"
  ]

  service = {
    id = konnect_gateway_service.flights.id
  }

  tags = ["act2", "documented", "governed", "flight-data", "discovered-dark-api"]
}

# Dark API: Seat map queries
resource "konnect_gateway_route" "flights_seats" {
  name = "flights-seats-route"
  paths = [
    "/flights/*/seats"
  ]

  service = {
    id = konnect_gateway_service.flights.id
  }

  tags = ["act2", "documented", "governed", "flight-data", "discovered-dark-api"]
}

# ============================================================================
# Routes Service Route
# ============================================================================

resource "konnect_gateway_route" "routes" {
  name = "routes-route"
  paths = [
    "/routes"
  ]

  service = {
    id = konnect_gateway_service.routes.id
  }

  tags = ["act2", "documented", "governed", "flight-data"]
}

# ============================================================================
# Customers Service Route
# ============================================================================

resource "konnect_gateway_route" "customers" {
  name = "customers-route"
  paths = [
    "/customers"
  ]

  service = {
    id = konnect_gateway_service.customers.id
  }

  tags = ["act2", "documented", "governed", "sales"]
}

# ============================================================================
# Bookings Service Route
# ============================================================================

resource "konnect_gateway_route" "bookings" {
  name = "bookings-route"
  paths = [
    "/bookings"
  ]

  service = {
    id = konnect_gateway_service.bookings.id
  }

  tags = ["act2", "documented", "governed", "sales"]
}

# ============================================================================
# Seating Service Routes
# ============================================================================

# Documented base path
resource "konnect_gateway_route" "seating_base" {
  name = "seating-base-route"
  paths = [
    "/seating"
  ]

  service = {
    id = konnect_gateway_service.seating.id
  }

  tags = ["act2", "documented", "governed", "seating"]
}

# Dark API: Seating map endpoint
resource "konnect_gateway_route" "seating_map" {
  name = "seating-map-route"
  paths = [
    "/seating/flights/*/seatingMap"
  ]

  service = {
    id = konnect_gateway_service.seating.id
  }

  tags = ["act2", "documented", "governed", "seating", "discovered-dark-api"]
}

# Dark API: Seat availability endpoint
resource "konnect_gateway_route" "seating_seats" {
  name = "seating-seats-route"
  paths = [
    "/seating/flights/*/seats"
  ]

  service = {
    id = konnect_gateway_service.seating.id
  }

  tags = ["act2", "documented", "governed", "seating", "discovered-dark-api"]
}

# ============================================================================
# Operations Service Routes
# ============================================================================

# Documented base path
resource "konnect_gateway_route" "operations_base" {
  name = "operations-base-route"
  paths = [
    "/operations"
  ]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act2", "documented", "governed", "operations"]
}

# Dark API: Flight status endpoint
resource "konnect_gateway_route" "operations_status" {
  name = "operations-status-route"
  paths = [
    "/operations/flights/*/status"
  ]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act2", "documented", "governed", "operations", "discovered-dark-api"]
}

# Dark API: Flight crew endpoint
resource "konnect_gateway_route" "operations_crew" {
  name = "operations-crew-route"
  paths = [
    "/operations/flights/*/crew"
  ]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act2", "documented", "governed", "operations", "discovered-dark-api"]
}

# Dark API: Flight gate endpoint
resource "konnect_gateway_route" "operations_gate" {
  name = "operations-gate-route"
  paths = [
    "/operations/flights/*/gate"
  ]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act2", "documented", "governed", "operations", "discovered-dark-api"]
}

# ============================================================================
# Ancillary Service Routes
# ============================================================================

# Documented base path
resource "konnect_gateway_route" "ancillary_base" {
  name = "ancillary-base-route"
  paths = [
    "/ancillary"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act2", "documented", "governed", "ancillary"]
}

# Dark API: Booking add-ons endpoint
resource "konnect_gateway_route" "ancillary_addons" {
  name = "ancillary-addons-route"
  paths = [
    "/ancillary/bookings/*/add-ons"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act2", "documented", "governed", "ancillary", "discovered-dark-api"]
}

# Dark API: Baggage policy endpoint
resource "konnect_gateway_route" "ancillary_baggage" {
  name = "ancillary-baggage-route"
  paths = [
    "/ancillary/routes/*/baggage-policy"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act2", "documented", "governed", "ancillary", "discovered-dark-api"]
}

# Dark API: Flight meals endpoint
resource "konnect_gateway_route" "ancillary_meals" {
  name = "ancillary-meals-route"
  paths = [
    "/ancillary/flights/*/meals"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act2", "documented", "governed", "ancillary", "discovered-dark-api"]
}

# Dark API: Meal preferences endpoint
resource "konnect_gateway_route" "ancillary_preferences" {
  name = "ancillary-preferences-route"
  paths = [
    "/ancillary/customer/*/meal-preferences"
  ]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act2", "documented", "governed", "ancillary", "discovered-dark-api"]
}

# ============================================================================
# Experience Service Route
# ============================================================================

resource "konnect_gateway_route" "experience" {
  name = "experience-route"
  paths = [
    "/experience"
  ]

  service = {
    id = konnect_gateway_service.experience.id
  }

  tags = ["act2", "documented", "governed", "experience"]
}

# ============================================================================
# Route ID Outputs
# ============================================================================

output "flights_base_route_id" {
  value = konnect_gateway_route.flights_base.id
}

output "flights_search_route_id" {
  value = konnect_gateway_route.flights_search.id
}

output "flights_history_route_id" {
  value = konnect_gateway_route.flights_history.id
}

output "flights_seats_route_id" {
  value = konnect_gateway_route.flights_seats.id
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

output "seating_base_route_id" {
  value = konnect_gateway_route.seating_base.id
}

output "seating_map_route_id" {
  value = konnect_gateway_route.seating_map.id
}

output "seating_seats_route_id" {
  value = konnect_gateway_route.seating_seats.id
}

output "operations_base_route_id" {
  value = konnect_gateway_route.operations_base.id
}

output "operations_status_route_id" {
  value = konnect_gateway_route.operations_status.id
}

output "operations_crew_route_id" {
  value = konnect_gateway_route.operations_crew.id
}

output "operations_gate_route_id" {
  value = konnect_gateway_route.operations_gate.id
}

output "ancillary_base_route_id" {
  value = konnect_gateway_route.ancillary_base.id
}

output "ancillary_addons_route_id" {
  value = konnect_gateway_route.ancillary_addons.id
}

output "ancillary_baggage_route_id" {
  value = konnect_gateway_route.ancillary_baggage.id
}

output "ancillary_meals_route_id" {
  value = konnect_gateway_route.ancillary_meals.id
}

output "ancillary_preferences_route_id" {
  value = konnect_gateway_route.ancillary_preferences.id
}

output "experience_route_id" {
  value = konnect_gateway_route.experience.id
}
