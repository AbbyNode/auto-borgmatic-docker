#!/bin/bash
set -euo pipefail

# Paths
: "${SCRIPTS_DIR:=/scripts}"
: "${TEMPLATES_DIR:=/templates}"
: "${CONFIG_DIR:=/config}"
: "${MINECRAFT_DIR:=/minecraft}"
: "${STARTSCRIPT:=startserver.sh}"

# If this file exists, modpack has been downloaded and extracted.
STARTSCRIPT_PATH="${MINECRAFT_DIR}/${STARTSCRIPT}"

DEFAULT_PROPS="${TEMPLATES_DIR}/default.properties"

# If this file exists, server is ready for post-setup tasks.
SERVER_PROPS="${MINECRAFT_DIR}/server.properties"

# If this file exists, first time setup is considered complete.
LINKED_PROPS="${CONFIG_DIR}/server.properties"

LOG_FILE="${MINECRAFT_DIR}/logs/modpack-setup.log"

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "${LOG_FILE}"
}
log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "${LOG_FILE}" >&2
}
log_warn() {
    echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "${LOG_FILE}" >&2
}
