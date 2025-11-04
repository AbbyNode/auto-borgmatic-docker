FROM itzg/minecraft-server:latest

# Hybrid image: Extends itzg/minecraft-server with CurseForge URL resolution
# 
# Features from itzg base:
# - GENERIC_PACK for direct modpack URLs
# - Custom start script support (automatic detection)
# - Server properties via environment variables
# - Optimized JVM flags, health checks, auto-restart
#
# Added features:
# - CurseForge page URL resolution without API key (web scraping)
#
# Usage with direct URL:
#   MODPACK_URL=https://mediafilez.forgecdn.net/files/.../ServerFiles.zip
# 
# Usage with CurseForge page URL:
#   MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
#   The wrapper resolves this to a direct URL automatically

# Add URL resolution wrapper script
COPY scripts/resolve-url-wrapper.sh /usr/local/bin/resolve-url-wrapper.sh
RUN chmod +x /usr/local/bin/resolve-url-wrapper.sh

# Use wrapper entrypoint that resolves URLs then calls itzg entrypoint
ENTRYPOINT ["/usr/local/bin/resolve-url-wrapper.sh"]
