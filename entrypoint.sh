#!/bin/bash
set -e

# Use STARTSCRIPT from .env or default to startserver.sh
: ${STARTSCRIPT:=./startserver.sh}

# Only download and extract modpack if the entrypoint script doesn't exist
if [ ! -f "${STARTSCRIPT#./}" ]; then
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

    # Ensure the entrypoint script exists after extraction
    if [ ! -f "${STARTSCRIPT#./}" ]; then
        echo "${STARTSCRIPT} not found in /minecraft. Please ensure the modpack includes it."
        exit 1
    fi

    # Make the entrypoint script executable
    chmod +x "${STARTSCRIPT#./}"
else
    echo "Server files already exist (${STARTSCRIPT} found), skipping download."
fi

# Automatically accept the EULA
echo "Accepting Minecraft EULA..."
echo "eula=true" > /minecraft/eula.txt

echo "Running ${STARTSCRIPT}..."
exec /bin/bash "${STARTSCRIPT#./}"
