#!/bin/bash
set -e

# Wrapper entrypoint for hybrid itzg image
# Resolves CurseForge page URLs to direct server file URLs, then calls itzg entrypoint

SHARED_DIR="${SHARED_DIR:-/opt/shared}"
# shellcheck disable=SC1091
[ -f "$SHARED_DIR/lib/log.sh" ] && source "$SHARED_DIR/lib/log.sh"
# Fallback logging if shared lib is unavailable
if ! command -v log_info >/dev/null 2>&1; then
    log_info() { echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"; }
    log_error() { echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2; }
fi

resolve_if_needed() {
    if [ -z "${MODPACK_URL:-}" ]; then
        return
    fi
    if echo "${MODPACK_URL}" | grep -qE '^https?://(www\.)?curseforge\.com/minecraft/modpacks/[a-zA-Z0-9_-]+/?$'; then
        log_info "Detected CurseForge modpack page URL, resolving to server files..."
        if [ -x "$SHARED_DIR/url/resolve-curseforge-url.sh" ]; then
            local url
            if ! url=$("$SHARED_DIR/url/resolve-curseforge-url.sh" "${MODPACK_URL}"); then
                log_error "Failed to resolve CurseForge URL"
                exit 1
            fi
            log_info "Resolved to: ${url}"
            export GENERIC_PACK="${url}"
        else
            log_error "Shared resolver not found at $SHARED_DIR/url/resolve-curseforge-url.sh"
            exit 1
        fi
    else
        log_info "Using direct URL: ${MODPACK_URL}"
        export GENERIC_PACK="${MODPACK_URL}"
    fi
}

resolve_if_needed

log_info "Starting itzg/minecraft-server..."
exec /start
