#!/bin/bash
set -euo pipefail

# This script will run STARTSCRIPT for the first time to generate default files,
# accept the EULA, and then modify server.properties based on default.properties.
# Then restart STARTSCRIPT to start the server normally.

source "$(dirname "$0")/common.sh"


# ========================================
#region Download and EULA
# ========================================

log_info "============ Starting first time server setup ============"

log_info "Creating Minecraft directory at ${MINECRAFT_DIR}..."
mkdir -p "${MINECRAFT_DIR}"

# Download modpack if needed
if [ ! -f "${STARTSCRIPT_PATH}" ]; then
    log_info "Start script not found at ${STARTSCRIPT_PATH}"
    bash "${SCRIPTS_DIR}/download.sh"
else
    log_info "Start script found at ${STARTSCRIPT_PATH}, skipping download..."
fi

log_info "Accepting Minecraft EULA..."
echo "eula=true" > "${MINECRAFT_DIR}/eula.txt"

#endregion


# ========================================
#region Generate default files
# ========================================

# Run STARTSCRIPT in background to generate default files
log_info "============ Running ${STARTSCRIPT_PATH} to generate default files ============"
bash "${STARTSCRIPT_PATH}" &
STARTSCRIPT_PID=$!

log_info "============ Waiting for world generation to complete ============"
WORLD_DIR="${MINECRAFT_DIR}/world"
MAX_WAIT=300  # 5 minutes maximum wait
ELAPSED=0

while [ $ELAPSED -lt $MAX_WAIT ]; do
    if [ -d "${WORLD_DIR}" ] && \
       [ -d "${WORLD_DIR}/data" ] && \
       [ -d "${WORLD_DIR}/region" ] && \
       [ -f "${WORLD_DIR}/level.dat" ] && \
       [ -f "${WORLD_DIR}/session.lock" ] && \
       [ -z "$(find "${WORLD_DIR}" -name '*.mca.tmp' 2>/dev/null)" ]; then
        log_info "World generation complete"
        break
    fi
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $MAX_WAIT ]; then
    log_warn "World generation check timed out after ${MAX_WAIT} seconds"
fi

# Update server.properties
bash "${SCRIPTS_DIR}/set-properties.sh"

# Kill the initial STARTSCRIPT process
log_info "============ Stopping initial ${STARTSCRIPT_PATH} process ============"
kill "${STARTSCRIPT_PID}" || true
wait "${STARTSCRIPT_PID}" 2>/dev/null || true

log_info "============ First time setup complete ============"

# Restart the server normally
exec "${SCRIPTS_DIR}/regular-run.sh"

#endregion
