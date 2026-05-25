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

# Act 2 — Governance & Standards environment
# This is pre-staged before the demo with full governance, Dev Portal, and standards enforcement
# It's the "hero state" that can't be broken during Act 1's live demo

variable "konnect_pat" {
  type        = string
  sensitive   = true
  description = "Konnect Personal Access Token"
}

# TBD: Define full governance setup:
# - Konnect gateway and data planes
# - All APIs fully documented
# - Dev Portal configured
# - Spectral rules enforced
# - Standards applied via submodule reference
