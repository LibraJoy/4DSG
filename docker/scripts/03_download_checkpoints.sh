#!/bin/bash

# 03_download_checkpoints.sh
# Download model checkpoints (can be run independently)

# This is just a wrapper around the existing download_checkpoints.sh
# but with better status reporting

set -e

echo "⬇️  Model Checkpoint Downloader"
echo "==============================="

# Check if checkpoint directories exist
if [ ! -d "../DovSG/checkpoints" ]; then
    echo "❌ Checkpoint directories not found!"
    echo "Please run: ./scripts/02_create_directories.sh first"
    exit 1
fi

echo "This will download ~8GB of model checkpoints."
echo "You can skip this and download later if needed."
echo ""

read -p "Download checkpoints now? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Get the directory of this script to call the download script
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    
    echo ""
    echo "🚀 Starting checkpoint download..."
    "$SCRIPT_DIR/download_checkpoints.sh"
    
    echo ""
    echo "🎉 Checkpoint download completed!"
else
    echo "⏭️  Skipping checkpoint download"
    echo ""
    echo "You can download checkpoints later by running:"
    echo "./scripts/download_checkpoints.sh"
fi

echo ""
echo "Next step: ./scripts/04_build_containers.sh"