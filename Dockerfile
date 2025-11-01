FROM eclipse-temurin:25-jre-alpine
RUN apk add --no-cache bash wget unzip

WORKDIR /minecraft

COPY ./entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
