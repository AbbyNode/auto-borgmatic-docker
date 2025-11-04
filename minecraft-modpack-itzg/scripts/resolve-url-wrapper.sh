#!/bin/bash
set -e

# Wrapper entrypoint for hybrid itzg image
# Resolves CurseForge page URLs to direct server file URLs, then calls itzg entrypoint
#
# If MODPACK_URL is set and is a CurseForge page URL, this script:
# 1. Resolves it to a direct server file URL
# 2. Sets GENERIC_PACK env var for itzg to use
# 3. Calls itzg's /start entrypoint
#
# If MODPACK_URL is already a direct URL, just passes it through to GENERIC_PACK

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $*"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2
}

# If MODPACK_URL is set, process it
if [ -n "${MODPACK_URL}" ]; then
    # Check if it's a CurseForge modpack page URL
    if echo "${MODPACK_URL}" | grep -qE '^https?://(www\.)?curseforge\.com/minecraft/modpacks/[a-zA-Z0-9_-]+/?$'; then
        log_info "Detected CurseForge modpack page URL, resolving to server files..."
        
        # Configuration
        PAGE_SIZE=20
        CURL_TIMEOUT=30
        USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        
        # Extract modpack slug
        MODPACK_SLUG=$(echo "${MODPACK_URL}" | sed -n 's|.*/modpacks/\([^/?]*\).*|\1|p')
        
        if [ -z "$MODPACK_SLUG" ]; then
            log_error "Failed to extract modpack slug from URL: ${MODPACK_URL}"
            exit 1
        fi
        
        log_info "Modpack slug: ${MODPACK_SLUG}"
        
        # Construct files list URL
        FILES_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/all?page=1&pageSize=${PAGE_SIZE}"
        log_info "Fetching files list from: ${FILES_URL}"
        
        # Download and search for server files
        TEMP_HTML=$(mktemp)
        if ! curl -L -A "${USER_AGENT}" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Language: en-US,en;q=0.5" \
            --max-time "${CURL_TIMEOUT}" \
            -s "${FILES_URL}" > "${TEMP_HTML}"; then
            log_error "Failed to fetch files list from CurseForge"
            rm -f "${TEMP_HTML}"
            exit 1
        fi
        
        # Check if we got actual content
        if [ ! -s "${TEMP_HTML}" ]; then
            log_error "Received empty response from CurseForge"
            rm -f "${TEMP_HTML}"
            exit 1
        fi
        
        log_info "Files page downloaded, searching for server files..."
        
        # Look for server filename
        SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "${TEMP_HTML}" | head -1 || true)
        
        if [ -n "${SERVER_FILENAME}" ]; then
            # Found a server filename, now find its file ID using literal match
            SERVER_FILE_ID=$(grep -iF "${SERVER_FILENAME}" "${TEMP_HTML}" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
            
            if [ -n "${SERVER_FILE_ID}" ]; then
                log_info "Found server file: ${SERVER_FILENAME} (ID: ${SERVER_FILE_ID})"
            else
                SERVER_FILENAME=""
            fi
        fi
        
        # If no server file found in main list, check additional files
        if [ -z "${SERVER_FILENAME}" ]; then
            log_info "No server files in main list, checking additional files..."
            
            # Extract file IDs
            FILE_IDS=$(grep -oE '/files/[0-9]+' "${TEMP_HTML}" | sed 's|/files/||' | sort -rn | uniq | head -3 || true)
            
            rm -f "${TEMP_HTML}"
            
            if [ -n "${FILE_IDS}" ]; then
                # Check first 3 files for additional server files
                for FILE_ID in ${FILE_IDS}; do
                    log_info "Checking additional files for file ID: ${FILE_ID}"
                    
                    ADDITIONAL_URL="https://www.curseforge.com/minecraft/modpacks/${MODPACK_SLUG}/files/${FILE_ID}/additional-files"
                    TEMP_ADDITIONAL=$(mktemp)
                    
                    if curl -L -A "${USER_AGENT}" \
                        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
                        --max-time "${CURL_TIMEOUT}" \
                        -s "${ADDITIONAL_URL}" > "${TEMP_ADDITIONAL}" 2>/dev/null && [ -s "${TEMP_ADDITIONAL}" ]; then
                        
                        SERVER_FILENAME=$(grep -io 'server[^"<>]*\.zip' "${TEMP_ADDITIONAL}" | head -1 || true)
                        
                        if [ -n "${SERVER_FILENAME}" ]; then
                            SERVER_FILE_ID=$(grep -iF "${SERVER_FILENAME}" "${TEMP_ADDITIONAL}" | sed -n 's|.*/files/\([0-9]\+\).*|\1|p' | head -1)
                            rm -f "${TEMP_ADDITIONAL}"
                            
                            if [ -n "${SERVER_FILE_ID}" ]; then
                                log_info "Found server file in additional files: ${SERVER_FILENAME} (ID: ${SERVER_FILE_ID})"
                                break
                            else
                                SERVER_FILENAME=""
                            fi
                        fi
                    fi
                    
                    rm -f "${TEMP_ADDITIONAL}"
                done
            fi
        else
            rm -f "${TEMP_HTML}"
        fi
        
        if [ -z "${SERVER_FILENAME}" ] || [ -z "${SERVER_FILE_ID}" ]; then
            log_error "No server files found for modpack: ${MODPACK_URL}"
            log_error "Please use a direct server file URL instead"
            exit 1
        fi
        
        # Construct the direct download URL
        # Format: https://mediafilez.forgecdn.net/files/XXXX/YYY/filename.zip
        # File ID is split: last 3 digits become PART2, everything before becomes PART1
        if [ ${#SERVER_FILE_ID} -lt 4 ]; then
            log_error "File ID '${SERVER_FILE_ID}' is too short (< 4 digits) to construct a valid download URL"
            exit 1
        fi
        
        # Split file ID: everything except last 3 digits / last 3 digits
        PART1="${SERVER_FILE_ID:0:${#SERVER_FILE_ID}-3}"
        PART2="${SERVER_FILE_ID: -3}"
        
        RESOLVED_URL="https://mediafilez.forgecdn.net/files/${PART1}/${PART2}/${SERVER_FILENAME}"
        
        log_info "Resolved to: ${RESOLVED_URL}"
        export GENERIC_PACK="${RESOLVED_URL}"
    else
        # Direct URL, just pass it through
        log_info "Using direct URL: ${MODPACK_URL}"
        export GENERIC_PACK="${MODPACK_URL}"
    fi
fi

# Call itzg's original entrypoint
log_info "Starting itzg/minecraft-server..."
exec /start
