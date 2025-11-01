#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

if [ -z "${MODPACK_URL:-}" ]; then
    log_warn "No MODPACK_URL provided and start script not found"
    exit 1
fi

# Download modpack to temporary directory
DOWNLOAD_DIR=$(mktemp -d)
log_info "============ Downloading modpack from ${MODPACK_URL} ============"
wget --content-disposition --progress=bar:force -P "${DOWNLOAD_DIR}" "${MODPACK_URL}"
log_info "Download successful"

# Find the downloaded file
MODPACK_FILE=$(find "${DOWNLOAD_DIR}" -maxdepth 1 -type f | head -n 1)
if [ -z "${MODPACK_FILE}" ]; then
    log_error "Failed to find downloaded modpack file in ${DOWNLOAD_DIR}"
    rm -rf "${DOWNLOAD_DIR}"
    exit 1
fi

log_info "============ Extracting modpack from ${MODPACK_FILE} ============"
if unzip -q "${MODPACK_FILE}" -d "${MINECRAFT_DIR}"; then
    log_info "Extraction successful"
    rm -rf "${DOWNLOAD_DIR}"
    log_info "Cleaned up modpack archive"
else
    log_error "Failed to extract modpack"
    rm -rf "${DOWNLOAD_DIR}"
    exit 1
fi

# Verify start script exists and make executable
if [ ! -f "${STARTSCRIPT_PATH}" ]; then
    log_error "${STARTSCRIPT} not found at ${STARTSCRIPT_PATH}"
    exit 1
fi

chmod +x "${STARTSCRIPT_PATH}"
log_info "Modpack download complete"
