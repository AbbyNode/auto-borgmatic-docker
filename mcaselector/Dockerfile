# https://github.com/Querz/mcaselector

FROM eclipse-temurin:25-jre-alpine
RUN apk add --no-cache bash curl jq

WORKDIR /mcaselector

RUN \  
    release_json=$(curl --silent "https://api.github.com/repos/Querz/mcaselector/releases/latest") && \  
    latest_tag=$(echo "$release_json" | jq -r '.tag_name') && \  
    echo "Latest tag is $latest_tag" && \  
    download_url=$(echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url') && \  
    echo "Downloading from $download_url" && \  
    curl -L "$download_url" -o mcaselector.jar && \  
    chmod +x mcaselector.jar

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
