FROM eclipse-temurin:25-jre-alpine
RUN apk add --no-cache bash wget unzip curl grep sed

# Copy project-specific scripts and templates (subdir context)
COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

COPY ./templates /templates

EXPOSE 25565

ENTRYPOINT ["/scripts/entrypoint.sh"]
