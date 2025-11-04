#!/bin/sh
set -e

echo "===== Unmined Map Generation ====="
echo "Starting map generation at $(date)"

# Check if world directory exists
if [ ! -d "/world" ]; then
    echo "ERROR: World directory not found at /world"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p /output

# Run unmined-cli to generate web-based map
echo "Generating web-based map from /world to /output..."
/unmined/unmined-cli web render --world=/world --output=/output

echo "Map generation completed at $(date)"
echo "===== End of Unmined Map Generation ====="
