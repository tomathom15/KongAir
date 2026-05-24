terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = "~> 0.10.0"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_pat
  server_url            = "https://us.api.konghq.com" # US region
}

# Act 1 — Dark APIs environment
# This is where the live demo pipeline deploys to
# It starts blank and gets populated as the pipeline runs

variable "konnect_pat" {
  type        = string
  sensitive   = true
  description = "Konnect Personal Access Token"
}

# TBD: Define Konnect gateway, data planes, and initial API configs
