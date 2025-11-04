# Minecraft Modded Server

Run a Minecraft modded server with automated backups and chunk cleanup. Uses [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) as the base with CurseForge URL resolution.

## Quick Start

```bash
# Download docker-compose.yml
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml

# Run setup container (creates .env, directories, and extracts scripts)
docker compose --profile setup run --rm setup

# Start the services
docker compose up -d
```

The setup container will:
- Create `.env` with default configuration
- Create required directory structure
- Create default `data/config/ofelia/config.ini`
- Extract version-controlled scripts to `data/setup-scripts/`

## Configuration

Edit `.env` to configure your modpack and server properties:

**Modpack URL - Direct server file URL** (recommended):

```bash
MODPACK_URL=https://mediafilez.forgecdn.net/files/7121/795/ServerFiles-4.14.zip
```

**Modpack URL - CurseForge page URL** (automatic resolution):

```bash
MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
```

**Set backup passphrase** (required for encryption):

```bash
BORG_PASSPHRASE=your-strong-passphrase
```

```bash
MODPACK_URL=https://www.curseforge.com/minecraft/modpacks/all-the-mods-10
```

**Set backup passphrase** (required for encryption):

```bash
BORG_PASSPHRASE=your-strong-passphrase

```bash
BORG_PASSPHRASE=your-strong-passphrase
```

## How It Works

This setup uses a hybrid approach:
- **Base**: [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server) (community-maintained, 1000+ contributors)
- **Added**: CurseForge page URL resolution without API key
- **Supports**: Custom start scripts if present in modpack
- **Fallback**: itzg's optimized launcher with Aikar flags

All server files are accessible in `./data/` (world, config, mods, logs).

## Server Management

### View Logs

```bash
docker compose logs -f minecraft-modpack
```

### Interactive Console

```bash
docker attach minecraft-modpack  # Ctrl+P, Ctrl+Q to detach
```

### Start/Stop

```bash
docker compose down
docker compose up --pull missing -d
```

## Automated Tasks

### Backups (Daily 7:00 AM)

Backs up world, config, mods, and logs to `./data/backups/borg-repository` with retention of 7 daily, 4 weekly, 6 monthly backups.

```bash
# Manual backup
docker exec borgmatic /scripts/backup.sh

# List backups
docker exec borgmatic borgmatic list

# Restore
docker exec borgmatic borgmatic extract --archive <name> --destination /tmp/restore
docker cp borgmatic:/tmp/restore ./restore/
```

**Configuration:** `./data/config/borgmatic/config.yaml` (auto-created on first run)

### Chunk Cleanup (Daily 7:00 AM)

Deletes old chunks based on age and player activity to save disk space.

**Default rules:**

- Not updated in 30 days + <2 hours player time
- Not updated in 7 days + <1 hour player time
- Not updated in 12 hours + <15 minutes player time
- Not updated in 1 hour + <5 minutes player time

```bash
# Manual cleanup
docker exec mcaselector /scripts/delete-chunks.sh
```

**Configuration:** `./data/config/mcaselector-options.yaml` (auto-created on first run)

### Job Scheduling
Customize schedules in `data/config/ofelia/config.ini` using cron syntax, then restart:
```bash
docker compose restart ofelia
```

## Additional Documentation

- **[Architecture](docs/Architecture.md)** - System design and component overview
- **[Bind Mounts](docs/bind-mounts.md)** - Host-container path mappings
- **[MCASelector CLI](mcaselector/docs/CLI-Mode.md)** - Command-line reference
- **[Chunk Filters](mcaselector/docs/Chunk-Filter.md)** - Chunk filtering options
