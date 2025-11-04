#!/bin/bash
set -euo pipefail

# Internal paths
MINECRAFT_DIR="/minecraft"
CONFIG_DIR="/config"
SCRIPTS_DIR="/scripts"
TEMPLATES_DIR="/templates"

# Configurable vars
: "${STARTSCRIPT:=startserver.sh}"
STARTSCRIPT_PATH="${MINECRAFT_DIR}/${STARTSCRIPT}" # If this file exists, modpack has been downloaded and extracted.

# Minecraft subdirectories
WORLD_DIR="${MINECRAFT_DIR}/world"
MODS_DIR="${MINECRAFT_DIR}/mods"
LOGS_DIR="${MINECRAFT_DIR}/logs"

# Properties files
DEFAULT_PROPS="${TEMPLATES_DIR}/default.properties"
SERVER_PROPS="${MINECRAFT_DIR}/server.properties" # If this file exists, server is ready for post-setup tasks.
LINKED_PROPS="${CONFIG_DIR}/server.properties" # If this file exists, first time setup is considered complete.

# Shared logging: if LOG_FILE is set, shared log functions will append to it.
LOG_FILE="${LOGS_DIR}/modpack-setup.log"
SHARED_DIR="${SHARED_DIR:-/opt/shared}"
# shellcheck disable=SC1091
[ -f "$SHARED_DIR/lib/log.sh" ] && source "$SHARED_DIR/lib/log.sh"
