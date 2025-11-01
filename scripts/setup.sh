#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Skip if already completed
if [ -f "${SETUP_COMPLETE_FLAG}" ]; then
    log_info "Setup already completed, skipping..."
    exit 0
fi

log_info "=== Starting first time server setup ==="

log_info "Creating Minecraft directory at ${MINECRAFT_DIR}..."
mkdir -p "${MINECRAFT_DIR}"

log_info "Accepting Minecraft EULA..."
echo "eula=true" > "${MINECRAFT_DIR}/eula.txt"

# Link existing files


# Set proper permissions
log_info "Setting permissions..."
chmod -R 755 "${MINECRAFT_DIR}" 2>/dev/null || true
chmod 644 "${MINECRAFT_DIR}"/*.json 2>/dev/null || true

post_start_setup() {
    if [ ! -f "${MINECRAFT_DIR}/server.properties" ]; then
        log_error "server.properties not found at ${MINECRAFT_DIR}/server.properties"
        exit 1
    fi

    log_info "Configuring server.properties..."
    
    # Read default properties and update server.properties
    DEFAULT_PROPS="${SCRIPTS_DIR}/default.properties"
    SERVER_PROPS="${MINECRAFT_DIR}/server.properties"
    
    if [ ! -f "${DEFAULT_PROPS}" ]; then
        log_error "default.properties not found at ${DEFAULT_PROPS}"
        exit 1
    fi
    
    # Process each property from default.properties
    while IFS='=' read -r key value || [ -n "$key" ]; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Update the property if it exists in server.properties
        if grep -q "^${key}=" "${SERVER_PROPS}"; then
            sed -i "s|^${key}=.*|${key}=${value}|" "${SERVER_PROPS}"
            log_info "Updated ${key}=${value}"
        fi
    done < "${DEFAULT_PROPS}"

    # Mark setup as complete
    touch "${SETUP_COMPLETE_FLAG}"
    log_info "=== Setup Complete ==="
}

log_info "Waiting for server to initialize for post-start setup..."
(
    while [ ! -f "${READY_FOR_SETUP_FLAG}" ]; do
        sleep 5
    done
    post_start_setup
) &
