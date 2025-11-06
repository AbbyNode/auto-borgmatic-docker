# Use official borgmatic image as base
FROM ghcr.io/borgmatic-collective/borgmatic:latest

# Copy setup script
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["/usr/local/bin/setup.sh"]
