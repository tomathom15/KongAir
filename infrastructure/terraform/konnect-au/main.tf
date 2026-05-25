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

variable "control_plane_id" {
  type        = string
  description = "Konnect Control Plane ID for Act 2 (APIOpsHelsinki_AU_Act2)"
}

output "control_plane_id" {
  value       = var.control_plane_id
  description = "Control plane ID for services and routes"
}
