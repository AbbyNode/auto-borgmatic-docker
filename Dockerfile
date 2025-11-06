# Use official borgmatic image
FROM ghcr.io/borgmatic-collective/borgmatic:latest

# Copy scripts
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

# Copy templates
COPY ./templates /templates

ENTRYPOINT ["/scripts/entrypoint.sh"]
