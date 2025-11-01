#!/bin/bash
set -e

# Check if the modpack URL is provided
if [ -n "$MODPACK_URL" ]; then
    echo "MODPACK_URL: $MODPACK_URL"
    echo "Downloading modpack from $MODPACK_URL..."
    wget --content-disposition -P /minecraft "$MODPACK_URL" || { echo "Failed to download modpack"; exit 1; }
    
    # Find the downloaded file (assumes only one file is downloaded)
    MODPACK_FILE=$(ls /minecraft | grep -E '\.zip$')
    if [ -z "$MODPACK_FILE" ]; then
        echo "Failed to find downloaded modpack file in /minecraft."
        exit 1
    fi

    echo "Extracting modpack..."
    unzip "/minecraft/$MODPACK_FILE" -d /minecraft || { echo "Failed to extract modpack"; exit 1; }
fi

# Ensure the startserver.sh file exists
if [ ! -f "/minecraft/startserver.sh" ]; then
    echo "startserver.sh not found in /minecraft. Please ensure the modpack includes it."
    exit 1
fi

# Automatically accept the EULA
echo "Accepting Minecraft EULA..."
echo "eula=true" > /minecraft/eula.txt

# Make startserver.sh executable
chmod +x /minecraft/startserver.sh

echo "Running startserver.sh..."
exec /bin/bash /minecraft/startserver.sh
