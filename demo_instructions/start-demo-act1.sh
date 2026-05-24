#!/bin/bash

set -e

echo "=================================================="
echo "KongAir Demo - Act 1: The Problem"
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
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Warning: Currently on branch '$CURRENT_BRANCH'"
    echo "Act 1 demo uses the 'main' branch"
    read -p "Switch to main branch? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout main
        echo "✓ Switched to main branch"
    else
        echo "Continuing on current branch..."
    fi
fi
echo ""

# Ensure we're in the right directory
if [ ! -f "docker-compose-orbstack.yaml" ]; then
    echo "Error: docker-compose-orbstack.yaml not found"
    echo "Please run this script from the KongAir root directory"
    exit 1
fi

echo "Starting KongAir Act 1 services..."
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
echo "Act 1 Demo is Running!"
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
echo "1. In Insomnia, import the 'KongAir - Act 1' collection"
echo "2. Notice the dark APIs: undocumented endpoints for:"
echo "   - GET /flights/{flightId}/seatingMap"
echo "   - GET /flights/{flightId}/seats"
echo "   - GET /flights/{flightId}/status"
echo "   - GET /flights/{flightId}/crew"
echo "   - GET /flights/{flightId}/gate"
echo "   - GET /bookings/{bookingId}/add-ons"
echo "   - POST /bookings/{bookingId}/add-ons"
echo "   - GET /routes/{routeId}/baggage-policy"
echo "   - GET /flights/{flightId}/meals"
echo "   - GET /customer/{customerId}/meal-preferences"
echo ""
echo "3. Observe:"
echo "   - No consistent API documentation"
echo "   - Inconsistent response formats"
echo "   - No governance or API contracts"
echo "   - Hard to discover and maintain"
echo ""
echo "4. View Kong Admin API to see unconfigured services:"
echo "   curl http://localhost:8001/services"
echo ""
echo "To switch to Act 2 and see the solution, run:"
echo "   ./start-demo-act2.sh"
echo ""
echo "To stop the demo, run:"
echo "   ./stop-demo.sh"
echo ""
