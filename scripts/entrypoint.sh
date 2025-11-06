#!/bin/bash
set -e

# Ensure config directory exists
mkdir -p /etc/borgmatic.d

# Ensure config file exists - copy template if not present
if [ ! -f /etc/borgmatic.d/config.yaml ]; then
    echo "Copying default borgmatic configuration..."
    cp /templates/borgmatic-config.yaml /etc/borgmatic.d/config.yaml
fi

# Ensure borg cache and config directories exist
mkdir -p /root/.config/borg
mkdir -p /root/.cache/borg
mkdir -p /root/.local/state/borgmatic

# Check if repository exists, if not initialize it
if [ ! -d /mnt/borg-repository/data ] && [ ! -f /mnt/borg-repository/README ]; then
    echo "Initializing borg repository..."
    borgmatic init --encryption repokey-blake2 --verbosity 1
    echo "Repository initialized successfully"
fi

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Default: run borgmatic in foreground mode
    echo "Borgmatic is ready. Use 'docker exec' to run backups manually."
    echo "Example: docker exec borgmatic borgmatic --stats --verbosity 1"
    # Keep container running
    exec tail -f /dev/null
fi
