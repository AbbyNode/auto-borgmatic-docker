# Minecraft Modded Server

Quick setup guide for running a Minecraft modded server with Docker.

## Setup

```bash
# Download required files
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/templates/.env.example

# Run
docker compose up -d

# Show logs
docker compose logs minecraft-modpack
```

## Edit `.env` to configure your modpack:
Modify the `MODPACK_URL` in `.env` to use a different modpack.
```
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
STARTSCRIPT=startserver.sh
```

## **Run the server:**
```bash
```
