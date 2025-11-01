#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Link any existing .json files
shopt -s nullglob
for file in "${CONFIG_DIR}"/*.json; do
    log_info "Linking $(basename "$file") to Minecraft directory..."
    ln -sf "$file" "${MINECRAFT_DIR}/$(basename "$file")"
done
shopt -u nullglob

# Set proper permissions
log_info "Setting permissions..."
chmod -R 755 "${MINECRAFT_DIR}" 2>/dev/null || true
chmod 644 "${MINECRAFT_DIR}"/*.json 2>/dev/null || true

# Link existing server.properties
log_info "Linking existing server.properties from config..."
ln -sf "${LINKED_PROPS}" "${SERVER_PROPS}"

log_info "Starting Minecraft server with ${STARTSCRIPT_PATH}..."
exec /bin/bash "${STARTSCRIPT_PATH}"
