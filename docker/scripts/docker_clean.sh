#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "Stopping and removing containers, networks, and volumes for this project..."
docker compose down --volumes

echo "✓ Cleanup complete"
echo "Note: This does NOT remove the built docker images. To do that, run 'docker image rm <image_name>'."
