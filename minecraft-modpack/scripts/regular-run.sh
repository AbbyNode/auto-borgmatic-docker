#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

log_info "============ Linking existing server.properties from config ============"
if [ ! -f "${LINKED_PROPS}" ]; then
    log_error "Linked server.properties not found at ${LINKED_PROPS}. Please run first-time-run.sh first."
    exit 1
fi
ln -sf "${LINKED_PROPS}" "${SERVER_PROPS}"

log_info "============ Linking existing .json files from config ============"
shopt -s nullglob
for file in "${CONFIG_DIR}"/*.json; do
    log_info "Linking $(basename "$file") to Minecraft directory..."
    ln -sf "$file" "${MINECRAFT_DIR}/$(basename "$file")"
done
shopt -u nullglob

log_info "Setting permissions..."
chmod -R 755 "${MINECRAFT_DIR}" 2>/dev/null || true
chmod 644 "${MINECRAFT_DIR}"/*.json 2>/dev/null || true

log_info "============ Starting Minecraft server with ${STARTSCRIPT_PATH} ============"
exec /bin/bash "${STARTSCRIPT_PATH}"
