#!/bin/bash
set -e

echo "======================================"
echo "Starting Borgmatic Backup"
echo "Time: $(date)"
echo "======================================"

# Run borgmatic backup with stats and verbosity
borgmatic --stats --verbosity 1 --files
local exit_code=$?

if (( exit_code == 0 )); then
    echo "======================================"
    echo "Backup completed successfully"
    echo "Time: $(date)"
    echo "======================================"
else
    echo "======================================"
    echo "Backup failed with exit code: $exit_code"
    echo "Time: $(date)"
    echo "======================================"
    exit "$exit_code"
fi
