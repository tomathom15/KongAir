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
  server_url            = "https://au.api.konghq.com" # AU region
}

variable "konnect_pat" {
  type        = string
  sensitive   = true
  description = "Konnect Personal Access Token"
}

# Act 2 Control Plane — Full Documentation + Governance
# This control plane has all APIs documented including previously dark endpoints
# Ready for governance policies (rate limiting, auth, request validation)

resource "konnect_gateway_control_plane" "act2" {
  name         = "KongAir Act 2"
  description  = "Act 2: Full Documentation + Governance (Dark APIs Now Documented)"
  cluster_type = "CLUSTER_TYPE_CONTROL_PLANE"
  auth_type    = "pinned_client_certs"
  cloud_gateway = true
}

output "control_plane_id" {
  value       = konnect_gateway_control_plane.act2.id
  description = "Control plane ID for services and routes"
}
