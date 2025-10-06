#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Building Docker images for DovSG..."
echo "This will take 15-30 minutes on first run."

docker compose build

echo "✓ Build complete"
echo "Next: Run './scripts/docker_run.sh' to start containers"
