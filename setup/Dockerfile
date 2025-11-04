FROM alpine:latest

# Copy setup scripts and templates (from repo root)
COPY setup/scripts/ /scripts/
COPY setup/templates/ /templates/
RUN chmod +x /scripts/*.sh

# Include shared libraries source, which will be copied into a named volume at runtime
COPY setup/shared/ /shared-src/

WORKDIR /workspace

ENTRYPOINT ["/scripts/init.sh"]
