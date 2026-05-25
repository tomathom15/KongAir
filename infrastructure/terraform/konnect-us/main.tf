terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = ">= 0.1"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_pat
  server_url            = "https://us.api.konghq.com" # US region
}

variable "konnect_pat" {
  type        = string
  sensitive   = true
  description = "Konnect Personal Access Token"
}

# Act 1 Control Plane — Base Paths Only
# Reference existing control plane configured with documented base paths only
# Dark APIs remain hidden/undiscovered

data "konnect_gateway_control_plane" "act1" {
  name = "APIOpsHelsinki_US_Act1"
}

output "control_plane_id" {
  value       = data.konnect_gateway_control_plane.act1.id
  description = "Control plane ID for services and routes"
}
