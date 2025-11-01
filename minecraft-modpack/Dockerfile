FROM eclipse-temurin:25-jre-alpine
RUN apk add --no-cache bash wget unzip

COPY ./scripts /scripts
RUN chmod +x /scripts/*.sh

COPY ./templates /templates

ENTRYPOINT ["/scripts/entrypoint.sh"]
