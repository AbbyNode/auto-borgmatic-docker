#!/bin/bash
set -e

# Create directory and symlink for ofelia config
mkdir -p /etc/ofelia
ln -sf /config/config.ini /etc/ofelia/config.ini

# Execute ofelia
exec /usr/bin/ofelia "$@"
