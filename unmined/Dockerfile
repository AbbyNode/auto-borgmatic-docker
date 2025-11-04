# https://unmined.net/

# Use .NET runtime Alpine image which has all required dependencies
FROM mcr.microsoft.com/dotnet/runtime:9.0-alpine

WORKDIR /unmined

# Download and install uNmINeD CLI for Linux musl-x64 (Alpine compatible)
RUN wget --no-check-certificate -O unmined-cli.tar.gz "https://unmined.net/download/unmined-cli-linux-musl-x64-dev/" && \
    tar -xzf unmined-cli.tar.gz && \
    rm unmined-cli.tar.gz && \
    mv unmined-cli_*/unmined-cli . && \
    mv unmined-cli_*/config . && \
    mv unmined-cli_*/templates ./unmined-templates && \
    rm -rf unmined-cli_* && \
    chmod +x unmined-cli

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

ENTRYPOINT ["/scripts/entrypoint.sh"]
