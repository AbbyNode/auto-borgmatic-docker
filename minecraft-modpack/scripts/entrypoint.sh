#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

if [ ! -f "${LINKED_PROPS}" ]; then
    log_info "Linked properties not detected, running first time setup..."
    exec "${SCRIPTS_DIR}/first-time-run.sh"
else
    log_info "Linked properties detected, skipping first time setup..."
    exec "${SCRIPTS_DIR}/regular-run.sh"
fi
