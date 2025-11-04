#!/usr/bin/env bash
# Shared logging helpers. Source this from any script.
# If LOG_FILE is set, logs are also appended there.

log__ts() {
    date '+%Y-%m-%d %H:%M:%S'
}

log_info() {
    local line="[INFO] $(log__ts) - $*"
    if [ -n "${LOG_FILE:-}" ]; then
        echo "$line" | tee -a "$LOG_FILE"
    else
        echo "$line"
    fi
}

log_warn() {
    local line="[WARN] $(log__ts) - $*"
    if [ -n "${LOG_FILE:-}" ]; then
        echo "$line" | tee -a "$LOG_FILE" >&2
    else
        echo "$line" >&2
    fi
}

log_error() {
    local line="[ERROR] $(log__ts) - $*"
    if [ -n "${LOG_FILE:-}" ]; then
        echo "$line" | tee -a "$LOG_FILE" >&2
    else
        echo "$line" >&2
    fi
}
