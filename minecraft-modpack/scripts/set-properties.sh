#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

# Process default.properties if it exists
if [ -f "${DEFAULT_PROPS}" ]; then
    log_info "default.properties found at ${DEFAULT_PROPS}"

    # Process each property from default.properties
    log_info "============ Configuring server.properties ============"
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
fi

# Copy the configured server.properties to linked location
cp "${SERVER_PROPS}" "${LINKED_PROPS}"
