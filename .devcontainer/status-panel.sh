#!/usr/bin/env bash

echo ""
echo "=============================================================="
echo "📊 Codespaces Status Panel (Live)"
echo "=============================================================="

# Show Docker status
echo ""
echo "🐳 Docker Status:"
docker info --format '{{json .}}' >/dev/null 2>&1 && echo "  ✓ Docker running" || echo "  ✗ Docker not running"

# Show n8n container status
echo ""
echo "🔧 n8n Container:"
if docker ps --format '{{.Names}}' | grep -q '^n8n$'; then
    echo "  ✓ n8n container running"
else
    echo "  ✗ n8n container not running"
fi

# Show port forwarding
echo ""
echo "🌐 Port Forwarding:"
docker ps --format '{{.Ports}}' | grep -q '5678->5678' && \
    echo "  ✓ Port 5678 forwarded" || \
    echo "  ✗ Port 5678 not forwarded"

# Show volume
echo ""
echo "💾 Volume:"
docker volume ls --format '{{.Name}}' | grep -q '^n8n_data$' && \
    echo "  ✓ n8n_data volume exists" || \
    echo "  ✗ n8n_data volume missing"

# Tail logs in background
echo ""
echo "📜 Live Logs (n8n):"
echo "--------------------------------------------------------------"
docker logs -f n8n 2>/dev/null &
