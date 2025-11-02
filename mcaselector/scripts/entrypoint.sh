#!/bin/bash

if [ -z "$RUN_FREQUENCY_CRON" ]; then
    echo "Error: RUN_FREQUENCY_CRON environment variable is not set."
    exit 1
fi

# Ensure config file exists
if [ ! -f /config/mcaselector-options.yaml ]; then
    cp /templates/mcaselector-options.yaml /config/mcaselector-options.yaml
fi

# Add cron job to root crontab
echo "$RUN_FREQUENCY_CRON /scripts/delete-chunks.sh >> /proc/1/fd/1 2>&1" >> /etc/crontabs/root

# Start cron in foreground (with verbose logging)
exec crond -f -l 8
