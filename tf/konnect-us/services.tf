# Kong Services for Act 1 Dark APIs
# In Act 1, services are configured with base paths only
# All sub-paths remain dark/undiscovered

# Seating Service
resource "konnect_gateway_service" "seating" {
  name = "seating-service"
  host = "seating.kongair"
  port = 5055
  protocol = "http"

  tags = ["act1", "dark-api", "seating"]
}

# Operations Service
resource "konnect_gateway_service" "operations" {
  name = "operations-service"
  host = "operations.kongair"
  port = 5056
  protocol = "http"

  tags = ["act1", "dark-api", "operations"]
}

# Ancillary Service
resource "konnect_gateway_service" "ancillary" {
  name = "ancillary-service"
  host = "ancillary.kongair"
  port = 5057
  protocol = "http"

  tags = ["act1", "dark-api", "ancillary"]
}

# Output service IDs for use in routes
output "seating_service_id" {
  value = konnect_gateway_service.seating.id
}

output "operations_service_id" {
  value = konnect_gateway_service.operations.id
}

output "ancillary_service_id" {
  value = konnect_gateway_service.ancillary.id
}
