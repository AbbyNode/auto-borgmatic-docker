#!/bin/bash
set -euo pipefail

# Thin shim kept for backward compatibility within this image.
# Delegates to the shared resolver in /opt/shared.

SHARED_DIR="${SHARED_DIR:-/opt/shared}"
if [ -f "$SHARED_DIR/url/resolve-curseforge-url.sh" ]; then
    exec "$SHARED_DIR/url/resolve-curseforge-url.sh" "$@"
else
    echo "Shared resolver not found at $SHARED_DIR/url/resolve-curseforge-url.sh" >&2
    exit 1
fi
