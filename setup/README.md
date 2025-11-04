# Setup Container

Provides initialization and wrapper scripts for the Minecraft modpack Docker environment.

## Usage

```bash
# Initial setup
docker compose --profile setup run --rm setup
```

Extracts version-controlled scripts to `data/setup-scripts/` and creates default configs in `data/config/`.

## Scripts

- `init.sh` - Creates .env, directories, and extracts scripts
- `ofelia-entrypoint.sh` - Wrapper for Ofelia that creates config symlinks

## Templates

- `.env.example` - Environment configuration
- `ofelia-config.ini` - Default Ofelia job schedules
