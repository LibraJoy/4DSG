#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [ "$1" = "--shell" ]; then
    echo "Starting containers and opening shell..."
    docker compose up -d
    docker compose exec dovsg bash
else
    echo "Starting DovSG containers..."
    docker compose up -d
    echo "✓ Containers running"
    docker compose ps
    echo ""
    echo "To enter a shell: ./scripts/docker_run.sh --shell"
fi
