# Kong Routes for Act 1 Dark APIs
# Base path routing to expose dark APIs through Kong gateway

# Seating Service Routes
resource "konnect_gateway_route" "seating" {
  name = "seating-route"
  paths = ["/seating"]

  service = {
    id = konnect_gateway_service.seating.id
  }

  tags = ["act1", "dark-api", "seating"]
}

# Operations Service Routes
resource "konnect_gateway_route" "operations" {
  name = "operations-route"
  paths = ["/operations"]

  service = {
    id = konnect_gateway_service.operations.id
  }

  tags = ["act1", "dark-api", "operations"]
}

# Ancillary Service Routes
resource "konnect_gateway_route" "ancillary" {
  name = "ancillary-route"
  paths = ["/ancillary"]

  service = {
    id = konnect_gateway_service.ancillary.id
  }

  tags = ["act1", "dark-api", "ancillary"]
}

# Output route IDs for verification
output "seating_route_id" {
  value = konnect_gateway_route.seating.id
}

output "operations_route_id" {
  value = konnect_gateway_route.operations.id
}

output "ancillary_route_id" {
  value = konnect_gateway_route.ancillary.id
}
