
# Host-Container Path Mappings

This document shows how paths on the host machine map to paths inside containers.

## Minecraft Modpack (itzg-based)

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `./data/` | `/data/` | All server data (world, logs, config, mods, libraries, etc.) |

## Borgmatic (Backups)

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `./data/` | `/mnt/source` (read-only) | Source data to backup |
| `./data/backups/borg-repository/` | `/mnt/borg-repository` | Borg repository storage |
| `./data/config/borgmatic/` | `/etc/borgmatic.d` | Borgmatic configuration |

## MCASelector (Chunk Management)

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `./data/world/` | `/world` | Minecraft world files |
| `./data/config/` | `/config` | MCASelector configuration |

## Ofelia (Job Scheduler)

| Host Path | Container Path | Description |
|-----------|----------------|-------------|
| `ofelia/config.ini` | `/etc/ofelia/config.ini` | Ofelia job configuration |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker socket for container management |

## Key Configuration Files

All configuration files are accessible in `./data/config/`:
- `./data/config/borgmatic/config.yaml` - Backup configuration
- `./data/config/mcaselector-options.yaml` - Chunk cleanup settings
- `./data/whitelist.json` - Whitelisted players
- `./data/ops.json` - Server operators
- `./data/banned-players.json` - Banned players
- `./data/server.properties` - Server properties (also configurable via env vars)

