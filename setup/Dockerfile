FROM alpine:latest

# Copy setup scripts and templates
COPY scripts/ /scripts/
COPY templates/ /templates/
RUN chmod +x /scripts/*.sh

WORKDIR /workspace

ENTRYPOINT ["/scripts/init.sh"]
