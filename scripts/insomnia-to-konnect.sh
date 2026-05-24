#!/bin/bash
# insomnia-to-konnect.sh
#
# Syncs an OAS spec edited in Insomnia to Kong Konnect via the APIOps pipeline.
# This demonstrates the developer-local → gateway workflow in action.
#
# Usage:
#   ./insomnia-to-konnect.sh <service> <region>
#
# Example:
#   ./insomnia-to-konnect.sh flight-data/flights us

set -e

SERVICE="${1:?Service required (e.g., flight-data/flights)}"
REGION="${2:?Region required (e.g., us or au)}"

echo "Syncing $SERVICE to Konnect region: $REGION"

# TBD: Implement wrapper around:
# - go-apiops build <service>
# - deck sync to Konnect <region>
# - Trigger GitHub Actions workflow (optional)

echo "Not yet implemented"
exit 1
