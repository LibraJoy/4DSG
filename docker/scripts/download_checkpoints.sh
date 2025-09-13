#!/bin/bash

# DovSG Checkpoints Download Script
# Downloads all publicly available model checkpoints

set -e

echo "🔽 DovSG Checkpoints Downloader"
echo "================================"

CHECKPOINTS_DIR="../DovSG/checkpoints"

# Create checkpoint directories
create_directories() {
    echo "📁 Creating checkpoint directories..."
    mkdir -p "$CHECKPOINTS_DIR"/{droid-slam,GroundingDINO,segment-anything-2,recognize_anything,bert-base-uncased,CLIP-ViT-H-14-laion2B-s32B-b79K,anygrasp}
    echo "✅ Directories created"
}

# Download DROID-SLAM checkpoint
download_droid_slam() {
    echo "⬇️  Downloading DROID-SLAM checkpoint..."
    if [ ! -f "$CHECKPOINTS_DIR/droid-slam/droid.pth" ]; then
        # Try direct download first, fallback to Google Drive ID
        wget -O "$CHECKPOINTS_DIR/droid-slam/droid.pth" \
            "https://drive.google.com/uc?export=download&id=1PpqVt1H4maBa_GbPJp4NwxRsd9jk-elh" \
            || echo "❌ DROID-SLAM download failed. Download manually from Google Drive."
    else
        echo "✅ DROID-SLAM checkpoint already exists"
    fi
}

# Download GroundingDINO checkpoints
download_groundingdino() {
    echo "⬇️  Downloading GroundingDINO checkpoint..."
    if [ ! -f "$CHECKPOINTS_DIR/GroundingDINO/groundingdino_swint_ogc.pth" ]; then
        wget -O "$CHECKPOINTS_DIR/GroundingDINO/groundingdino_swint_ogc.pth" \
            "https://github.com/IDEA-Research/GroundingDINO/releases/download/v0.1.0-alpha/groundingdino_swint_ogc.pth"
    fi
    
    if [ ! -f "$CHECKPOINTS_DIR/GroundingDINO/GroundingDINO_SwinT_OGC.py" ]; then
        wget -O "$CHECKPOINTS_DIR/GroundingDINO/GroundingDINO_SwinT_OGC.py" \
            "https://raw.githubusercontent.com/IDEA-Research/GroundingDINO/main/groundingdino/config/GroundingDINO_SwinT_OGC.py"
    fi
    echo "✅ GroundingDINO checkpoints downloaded"
}

# Download SAM2 checkpoint
download_sam2() {
    echo "⬇️  Downloading SAM2 checkpoint..."
    if [ ! -f "$CHECKPOINTS_DIR/segment-anything-2/sam2_hiera_large.pt" ]; then
        wget -O "$CHECKPOINTS_DIR/segment-anything-2/sam2_hiera_large.pt" \
            "https://dl.fbaipublicfiles.com/segment_anything_2/072824/sam2_hiera_large.pt"
    else
        echo "✅ SAM2 checkpoint already exists"
    fi
}

# Download RAM checkpoint
download_ram() {
    echo "⬇️  Downloading RAM checkpoint..."
    if [ ! -f "$CHECKPOINTS_DIR/recognize_anything/ram_swin_large_14m.pth" ]; then
        wget -O "$CHECKPOINTS_DIR/recognize_anything/ram_swin_large_14m.pth" \
            "https://huggingface.co/spaces/xinyu1205/Recognize_Anything-Tag2Text/resolve/main/ram_swin_large_14m.pth"
    else
        echo "✅ RAM checkpoint already exists"
    fi
}

# Download HuggingFace models (requires git-lfs)
download_huggingface_models() {
    echo "⬇️  Downloading HuggingFace models..."
    
    # Check if git-lfs is installed
    if ! command -v git-lfs &> /dev/null; then
        echo "⚠️  git-lfs not found. Installing..."
        sudo apt-get update && sudo apt-get install -y git-lfs
        git lfs install
    fi
    
    # BERT base uncased
    if [ ! -d "$CHECKPOINTS_DIR/bert-base-uncased" ]; then
        echo "Downloading BERT base uncased..."
        (cd "$CHECKPOINTS_DIR" && git clone https://huggingface.co/google-bert/bert-base-uncased)
    else
        echo "✅ BERT model directory already exists"
    fi
    
    # CLIP model
    if [ ! -d "$CHECKPOINTS_DIR/CLIP-ViT-H-14-laion2B-s32B-b79K" ]; then
        echo "Downloading CLIP model..."
        (cd "$CHECKPOINTS_DIR" && git clone https://huggingface.co/laion/CLIP-ViT-H-14-laion2B-s32B-b79K)
    else
        echo "✅ CLIP model directory already exists"
    fi
}

# Show manual download instructions
show_manual_instructions() {
    echo ""
    echo "📋 MANUAL DOWNLOAD REQUIRED:"
    echo "============================"
    echo ""
    echo "1. 🔑 AnyGrasp License:"
    echo "   - Register at: https://github.com/graspnet/anygrasp_sdk/blob/main/README.md#license-registration"
    echo "   - Place license files in: DovSG/license/"
    echo "   - Place checkpoints in: DovSG/checkpoints/anygrasp/"
    echo ""
    echo "2. 📊 Sample Data:"
    echo "   - Download from: https://drive.google.com/drive/folders/13v5QOrqjxye__kJwDIuD7kTdeSSNfR5x?usp=sharing"
    echo "   - Extract to: DovSG/data_example/room1/"
    echo ""
    echo "3. ⚠️  Failed Downloads:"
    echo "   - Check above for any failed downloads and download manually"
    echo ""
}

# Check download sizes
check_downloads() {
    echo ""
    echo "📊 Download Summary:"
    echo "==================="
    du -sh "$CHECKPOINTS_DIR"/* 2>/dev/null || echo "No checkpoints downloaded yet"
    echo ""
    echo "Expected total size: ~10GB"
    echo ""
}

# Main function
main() {
    create_directories
    
    echo ""
    read -p "Download all publicly available checkpoints? This will download ~8GB. (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        download_droid_slam
        download_groundingdino  
        download_sam2
        download_ram
        
        echo ""
        read -p "Download HuggingFace models (BERT, CLIP)? This requires git-lfs and adds ~2GB. (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            download_huggingface_models
        fi
    fi
    
    check_downloads
    show_manual_instructions
    
    echo "✅ Checkpoint download completed!"
    echo ""
    echo "Next steps:"
    echo "1. Complete manual downloads above"
    echo "2. Run: docker-compose build"  
    echo "3. Run: docker-compose up -d"
}

main "$@"