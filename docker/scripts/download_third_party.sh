#!/bin/bash
set -e

# Third-Party Dependency Downloader for DovSG
# Clones repositories at exact commits required by install_dovsg.md and install_droidslam.md

THIRD_PARTY_DIR="../DovSG/third_party"

cd "$(dirname "$0")"
mkdir -p "$THIRD_PARTY_DIR"
cd "$THIRD_PARTY_DIR"

echo "Downloading third-party dependencies..."

# Version Matrix (from install docs)
declare -A REPOS=(
    ["segment-anything-2"]="https://github.com/facebookresearch/sam2.git|7e1596c"
    ["GroundingDINO"]="https://github.com/IDEA-Research/GroundingDINO.git|856dde2"
    ["recognize-anything"]="https://github.com/xinyu1205/recognize-anything.git|88c2b0c"
    ["LightGlue"]="https://github.com/cvg/LightGlue.git|edb2b83"
    ["pytorch3d"]="https://github.com/facebookresearch/pytorch3d.git|05cbea1"
    ["DROID-SLAM"]="https://github.com/princeton-vl/DROID-SLAM.git|8016d2b"
)

for repo in "${!REPOS[@]}"; do
    IFS='|' read -r url commit <<< "${REPOS[$repo]}"

    echo "---"
    echo "Processing: $repo"

    if [ -d "$repo" ]; then
        echo "  Directory exists, checking commit..."
        cd "$repo"
        current_commit=$(git rev-parse --short HEAD)

        if [ "$current_commit" = "$commit" ]; then
            echo "  ✓ Already at correct commit $commit"
        else
            echo "  ⚠ Current: $current_commit, Required: $commit"
            echo "  Resetting to $commit..."
            git fetch origin
            git reset --hard "$commit"
            echo "  ✓ Reset to $commit"
        fi
        cd ..
    else
        echo "  Cloning from $url..."
        if git clone "$url" "$repo"; then
            cd "$repo"
            echo "  Checking out $commit..."
            git checkout "$commit"
            cd ..
            echo "  ✓ Cloned and checked out $commit"
        else
            echo "  ✗ FAILED to clone $repo"
            echo "  Manual fix: git clone $url $THIRD_PARTY_DIR/$repo && cd $THIRD_PARTY_DIR/$repo && git checkout $commit"
            exit 1
        fi
    fi
done

echo ""
echo "✓ All third-party dependencies ready"
echo ""
echo "IMPORTANT: Two files have local patches and are tracked in git:"
echo "  - segment-anything-2/setup.py (numpy/python version compatibility)"
echo "  - DROID-SLAM/droid_slam/trajectory_filler.py (depth parameter unpacking)"
echo ""
echo "These files will NOT be overwritten by this script."
echo "If you need to reset them: git checkout DovSG/third_party/<repo>/<file>"
