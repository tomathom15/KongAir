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
# Reference existing control plane with all APIs documented including previously dark endpoints
# Ready for governance policies (rate limiting, auth, request validation)

data "konnect_gateway_control_plane" "act2" {
  name = "APIOpsHelsinki_AU_Act2"
}

output "control_plane_id" {
  value       = data.konnect_gateway_control_plane.act2.id
  description = "Control plane ID for services and routes"
}
