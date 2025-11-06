# Use official borgmatic image
FROM ghcr.io/borgmatic-collective/borgmatic:latest

# Install additional tools that may be useful
RUN apk add --no-cache \
    bash \
    curl \
    jq

# Copy scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

# Copy templates
COPY ./templates /templates

ENTRYPOINT ["/scripts/entrypoint.sh"]
