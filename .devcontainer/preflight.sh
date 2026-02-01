#!/usr/bin/env bash

echo ""
echo "=============================================================="
echo "🔍 Running n8n Preflight Checks..."
echo "=============================================================="

# 1. Check Docker service
echo -n "🧩 Checking Docker service... "
if ! docker info >/dev/null 2>&1; then
    echo "❌ FAILED"
    echo "Docker is not running. Trying to start it..."
    sudo service docker start
    sleep 3
    if ! docker info >/dev/null 2>&1; then
        echo "❌ Docker could not start. Please reload the Codespace."
        exit 1
    fi
fi
echo "✅ OK"

# 2. Check n8n container
echo -n "🧩 Checking n8n container... "
if ! docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
    echo "❌ NOT RUNNING"
    echo "Attempting to start n8n..."
    docker-compose -f .devcontainer/docker-compose.yml up -d
    sleep 5
    if ! docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
        echo "❌ n8n failed to start. Check docker-compose logs."
        exit 1
    fi
fi
echo "✅ OK"

# 3. Check port 5678
echo -n "🧩 Checking port 5678... "
if ! docker ps --format '{{.Ports}}' | grep -q '5678->5678'; then
    echo "❌ PORT NOT FORWARDED"
    echo "Trying to restart n8n..."
    docker-compose -f .devcontainer/docker-compose.yml restart n8n
    sleep 5
fi
echo "✅ OK"

# 4. Check persistent volume
echo -n "🧩 Checking n8n_data volume... "
if ! docker volume ls --format '{{.Name}}' | grep -q '^n8n_data$'; then
    echo "❌ MISSING"
    echo "Creating volume..."
    docker volume create n8n_data >/dev/null
fi
echo "✅ OK"

echo ""
echo "=============================================================="
echo "🎉 Preflight checks complete!"
echo "n8n should be available on port 5678 shortly."
echo "If the browser tab didn't open automatically, open it from:"
echo "👉 VS Code → PORTS → 5678 → Open in Browser"
echo "=============================================================="
echo ""
