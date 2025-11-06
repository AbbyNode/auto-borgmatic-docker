#!/bin/bash
set -e

echo "=========================================="
echo "Initializing Auto-Borgmatic Container"
echo "=========================================="

# Ensure all required directories exist
echo "Creating required directories..."
mkdir -p /etc/borgmatic.d
mkdir -p /root/.config/borg
mkdir -p /root/.cache/borg
mkdir -p /root/.local/state/borgmatic
mkdir -p /mnt/borg-repository
mkdir -p /mnt/source

# Ensure config file exists - copy template if not present
if [ ! -f /etc/borgmatic.d/config.yaml ]; then
    echo "Generating default borgmatic configuration..."
    cp /templates/borgmatic-config.yaml /etc/borgmatic.d/config.yaml
    echo "✓ Configuration created at /etc/borgmatic.d/config.yaml"
else
    echo "✓ Using existing configuration"
fi

# Check if repository exists, if not initialize it
if [ ! -d /mnt/borg-repository/data ] && [ ! -f /mnt/borg-repository/README ]; then
    echo "Initializing borg repository..."
    
    # Check if BORG_PASSPHRASE is set
    if [ -z "$BORG_PASSPHRASE" ]; then
        echo "WARNING: BORG_PASSPHRASE not set. Using default passphrase."
        echo "For production use, set BORG_PASSPHRASE in .secrets file"
        export BORG_PASSPHRASE="change-me-in-production"
    fi
    
    borgmatic init --encryption repokey-blake2 --verbosity 1
    echo "✓ Repository initialized successfully"
else
    echo "✓ Repository already initialized"
fi

echo "=========================================="
echo "Borgmatic initialization complete!"
echo "=========================================="

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Default: run the scheduler
    echo "Starting backup scheduler..."
    exec /scripts/scheduler.sh
fi
