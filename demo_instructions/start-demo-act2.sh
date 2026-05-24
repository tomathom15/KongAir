#!/bin/bash

set -e

echo "=================================================="
echo "KongAir Demo - Act 2: The Solution"
echo "=================================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running"
    echo "Please start OrbStack or Docker Desktop"
    exit 1
fi

echo "✓ Docker is running"
echo ""

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "act2-standardized-services" ]; then
    echo "Switching to act2-standardized-services branch..."
    read -p "This will stop Act 1 and restart with Act 2 changes. Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 1
    fi

    # Stop current services
    echo "Stopping Act 1 services..."
    docker-compose -f docker-compose-orbstack.yaml down 2>/dev/null || true
    sleep 2

    # Switch branch
    git checkout act2-standardized-services
    echo "✓ Switched to act2-standardized-services branch"
fi
echo ""

# Ensure we're in the right directory
if [ ! -f "docker-compose-orbstack.yaml" ]; then
    echo "Error: docker-compose-orbstack.yaml not found"
    exit 1
fi

echo "Starting KongAir Act 2 services..."
echo ""

# Start services using OrbStack
docker-compose -f docker-compose-orbstack.yaml up -d

echo ""
echo "✓ Services starting..."
echo ""

# Wait for Kong to be ready
echo "Waiting for Kong Gateway to be ready..."
max_attempts=30
attempt=0
until curl -s http://localhost:8001 > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ $attempt -ge $max_attempts ]; then
        echo "Error: Kong Gateway failed to start"
        exit 1
    fi
    echo "  Attempt $attempt/$max_attempts..."
    sleep 2
done

echo "✓ Kong Gateway is ready"
echo ""

# Wait for traffic injector to stabilize
echo "Waiting for traffic injector..."
sleep 5
echo "✓ Traffic injector is running"
echo ""

echo "=================================================="
echo "Act 2 Demo is Running!"
echo "=================================================="
echo ""
echo "Services available at:"
echo "  - Kong Gateway (proxy):  http://localhost:8000"
echo "  - Kong Admin API:        http://localhost:8001"
echo "  - Experience service:    http://localhost:5050"
echo "  - Customers service:     http://localhost:5051"
echo "  - Flights service:       http://localhost:5052"
echo "  - Routes service:        http://localhost:5053"
echo "  - Bookings service:      http://localhost:5054"
echo "  - Seating service:       http://localhost:5055"
echo "  - Operations service:    http://localhost:5056"
echo "  - Ancillary service:     http://localhost:5057"
echo ""

echo "Next Steps:"
echo "1. In Insomnia, import the 'KongAir - Act 2' collection"
echo "2. Notice the improvements:"
echo "   - All APIs are documented and visible"
echo "   - Consistent request/response formats"
echo "   - OpenAPI specifications in Kong Konnect"
echo "   - Governance rules enforced by Kong Gateway"
echo ""
echo "3. Check Kong configuration to see:"
echo "   - Service definitions with proper paths"
echo "   - Routes configured with authentication"
echo "   - Plugins enforcing governance policies"
echo "   curl http://localhost:8001/services"
echo ""
echo "4. Review governance rules:"
echo "   - Rate limiting per API tier"
echo "   - Request/response validation"
echo "   - Service level agreements (SLAs)"
echo ""
echo "Governance Enforcements:"
echo "  - Seating Service: Rate limit 100 req/min per customer"
echo "  - Operations Service: Rate limit 50 req/min, requires authentication"
echo "  - Ancillary Service: Rate limit 200 req/min, validates request schema"
echo ""
echo "To go back to Act 1 and see the problem, run:"
echo "   ./start-demo-act1.sh"
echo ""
echo "To stop the demo, run:"
echo "   ./stop-demo.sh"
echo ""
