#!/bin/bash

# Test script for Airbyte Docker Compose stack
# This script validates the setup without fully running it

set -e

echo "=========================================="
echo "Airbyte Docker Compose Stack Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Test 1: Check if docker is installed
echo "Test 1: Checking Docker installation..."
if command -v docker &> /dev/null; then
    docker --version
    print_status 0 "Docker is installed"
else
    print_status 1 "Docker is not installed"
fi
echo ""

# Test 2: Check if docker compose is available
echo "Test 2: Checking Docker Compose..."
if docker compose version &> /dev/null; then
    docker compose version
    print_status 0 "Docker Compose is available"
else
    print_status 1 "Docker Compose is not available"
fi
echo ""

# Test 3: Validate docker-compose.yml syntax
echo "Test 3: Validating docker-compose.yml syntax..."
if docker compose config > /dev/null 2>&1; then
    print_status 0 "docker-compose.yml syntax is valid"
else
    print_status 1 "docker-compose.yml has syntax errors"
fi
echo ""

# Test 4: Check if .env file exists
echo "Test 4: Checking .env file..."
if [ -f .env ]; then
    print_status 0 ".env file exists"
else
    print_status 1 ".env file is missing"
fi
echo ""

# Test 5: Check if all required images can be pulled
echo "Test 5: Checking Docker images..."
IMAGES=(
    "airbyte/db:0.50.33"
    "airbyte/worker:0.50.33"
    "airbyte/server:0.50.33"
    "airbyte/webapp:0.50.33"
    "airbyte/temporal:0.50.33"
    "airbyte/cron:0.50.33"
    "airbyte/connector-builder-server:0.50.33"
)

ALL_IMAGES_OK=true
for image in "${IMAGES[@]}"; do
    if docker image inspect "$image" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $image"
    else
        echo -e "  ${RED}✗${NC} $image (not found)"
        ALL_IMAGES_OK=false
    fi
done

if [ "$ALL_IMAGES_OK" = true ]; then
    print_status 0 "All required Docker images are available"
else
    print_status 1 "Some Docker images are missing"
fi
echo ""

# Test 6: Check temporal configuration
echo "Test 6: Checking Temporal configuration..."
if [ -f temporal/development.yaml ]; then
    print_status 0 "Temporal configuration exists"
else
    print_status 1 "Temporal configuration is missing"
fi
echo ""

# Test 7: Validate environment variables
echo "Test 7: Validating environment variables..."
source .env
REQUIRED_VARS=(
    "VERSION"
    "DATABASE_USER"
    "DATABASE_PASSWORD"
    "DATABASE_URL"
)

ALL_VARS_OK=true
for var in "${REQUIRED_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        echo -e "  ${GREEN}✓${NC} $var is set"
    else
        echo -e "  ${RED}✗${NC} $var is not set"
        ALL_VARS_OK=false
    fi
done

if [ "$ALL_VARS_OK" = true ]; then
    print_status 0 "All required environment variables are set"
else
    print_status 1 "Some environment variables are missing"
fi
echo ""

# Test 8: Check port availability
echo "Test 8: Checking if required ports are available..."
PORTS=(8000 8001 8080)
ALL_PORTS_FREE=true

for port in "${PORTS[@]}"; do
    if ! lsof -i :$port &> /dev/null && ! netstat -tuln 2>/dev/null | grep ":$port " &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Port $port is available"
    else
        echo -e "  ${YELLOW}⚠${NC} Port $port is in use (this might cause issues)"
        ALL_PORTS_FREE=false
    fi
done

if [ "$ALL_PORTS_FREE" = true ]; then
    print_status 0 "All required ports are available"
else
    print_warning "Some ports are in use - may need to be freed"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}All validation tests passed!${NC}"
echo ""
echo "The Airbyte Docker Compose stack is properly configured."
echo ""
echo "To start the stack, run:"
echo "  docker compose up -d"
echo ""
echo "To view logs:"
echo "  docker compose logs -f"
echo ""
echo "To access Airbyte UI:"
echo "  http://localhost:8000"
echo ""
echo "To stop the stack:"
echo "  docker compose down"
echo ""
