#!/bin/bash
set -e

# Default backup interval (1 hour)
BACKUP_INTERVAL=${BACKUP_INTERVAL:-3600}

echo "=========================================="
echo "Borgmatic Backup Scheduler Started"
echo "Backup interval: ${BACKUP_INTERVAL} seconds"
echo "=========================================="

# Function to run backup
run_backup() {
    echo ""
    echo "=========================================="
    echo "Starting scheduled backup"
    echo "Time: $(date)"
    echo "=========================================="
    
    # Run the backup script
    if /scripts/backup.sh; then
        echo "✓ Backup completed successfully"
    else
        echo "✗ Backup failed"
    fi
    
    echo "Next backup in ${BACKUP_INTERVAL} seconds"
    echo "=========================================="
}

# Initial delay to allow system to stabilize
echo "Waiting 30 seconds before first backup..."
sleep 30

# Main backup loop
while true; do
    run_backup
    sleep "$BACKUP_INTERVAL"
done
