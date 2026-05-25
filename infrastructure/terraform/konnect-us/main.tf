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
# This control plane starts with only documented base paths
# Dark APIs remain hidden/undiscovered

resource "konnect_gateway_control_plane" "act1" {
  name         = "KongAir Act 1"
  description  = "Act 1: Base Paths Only (Dark APIs Hidden)"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE"
  auth_type    = "pinned_client_certs"
  cloud_gateway = true
}

output "control_plane_id" {
  value       = konnect_gateway_control_plane.act1.id
  description = "Control plane ID for services and routes"
}
