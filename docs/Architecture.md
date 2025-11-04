# Architecture

## System Overview

```mermaid
graph TB
    Ofelia[Ofelia<br/>Job Scheduler]
    Borgmatic[Borgmatic<br/>Backup Service]
    MCASelector[MCASelector<br/>Chunk Cleanup]
    Minecraft[Minecraft Server]
    
    Ofelia -->|Daily 7AM| Borgmatic
    Ofelia -->|Daily 7AM| MCASelector
    
    Borgmatic -.->|Reads| Data[(./data)]
    MCASelector -.->|Modifies| World[(./data/world)]
    Minecraft -->|Generates| Data
    Minecraft -->|Generates| World
    
    Borgmatic -->|Writes| Backups[(./data/backups)]
```

## Components

| Component | Image | Config Location |
|-----------|-------|-----------------|
| Ofelia | `mcuadros/ofelia:latest` (official) | `data/config/ofelia/config.ini` |
| Borgmatic | `eclarift/borgmatic:latest` | `./data/config/borgmatic/config.yaml` |
| MCASelector | `eclarift/mcaselector:latest` | `./data/config/mcaselector-options.yaml` |
| Setup | `eclarift/minecraft-setup:latest` | N/A (one-time setup) |
| Shared libs | (mounted volume) | `/opt/shared` |

## Setup Container

The setup container provides version-controlled initialization scripts and templates:

```
setup/
├── Dockerfile
├── scripts/{init.sh, ofelia-entrypoint.sh}
└── templates/{.env.example, ofelia-config.ini}
```

On first run, it extracts scripts to `data/setup-scripts/` and creates default configs in `data/config/`.

### Shared Utilities

Reusable bash helpers live under `setup/shared` and are mounted into containers at `/opt/shared` via a named volume populated by the `setup` service:

- `lib/log.sh` — consistent logging to stdout/stderr and optional `LOG_FILE` tee
- `url/resolve-curseforge-url.sh` — resolves CurseForge modpack pages to direct server file URLs

Services that need these utilities mount the `shared-scripts` volume read-only at `/opt/shared`. The `setup` service mounts it read-write and populates it during the setup step.

## Custom Docker Images

Custom images are built for Borgmatic and MCASelector to include project-specific scripts and templates:

```
borgmatic/
├── Dockerfile
├── scripts/{backup.sh, entrypoint.sh}
└── templates/borgmatic-config.yaml

mcaselector/
├── scripts/entrypoint.sh
└── templates/mcaselector-options.yaml
```
