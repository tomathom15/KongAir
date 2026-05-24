#!/bin/bash

set -e

echo "=================================================="
echo "KongAir Demo - Stopping Services"
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
    exit 1
fi

# Ensure we're in the right directory
if [ ! -f "docker-compose-orbstack.yaml" ]; then
    echo "Error: docker-compose-orbstack.yaml not found"
    echo "Please run this script from the KongAir root directory"
    exit 1
fi

echo "Stopping all KongAir services..."
echo ""

# Stop all services
docker-compose -f docker-compose-orbstack.yaml down

echo ""
echo "✓ All services stopped"
echo ""
echo "To run the demo again:"
echo "   ./start-demo-act1.sh   (for Act 1 - the problem)"
echo "   ./start-demo-act2.sh   (for Act 2 - the solution)"
echo ""
