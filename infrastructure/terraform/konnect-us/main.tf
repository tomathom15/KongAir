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

variable "control_plane_id" {
  type        = string
  description = "Konnect Control Plane ID for Act 1 (APIOpsHelsinki_US_Act1)"
}

output "control_plane_id" {
  value       = var.control_plane_id
  description = "Control plane ID for services and routes"
}
