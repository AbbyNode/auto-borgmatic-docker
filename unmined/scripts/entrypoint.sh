#!/bin/sh
set -e

# If a command was provided, execute it
if [ $# -gt 0 ]; then
    exec "$@"
else
    # Keep container running for Ofelia to execute jobs
    echo "Unmined is ready. Jobs are scheduled via Ofelia."
    echo "Manual run: docker exec unmined /scripts/generate-map.sh"
    exec tail -f /dev/null
fi
