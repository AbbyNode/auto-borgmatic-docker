# Auto-Borgmatic Docker

Automated borgmatic backups for game servers and applications with minimal setup. Each instance gets its own borg repository with automatic initialization and scheduled backups.

## Quick Start

1. **Download the compose file**
   ```bash
   wget https://raw.githubusercontent.com/AbbyNode/auto-borgmatic-docker/main/docker-compose.yml
   ```

2. **Run it**
   ```bash
   docker compose up -d
   ```

That's it! The container will:
- Auto-create all necessary directories
- Initialize the borg repository
- Generate a default configuration
- Start backing up on a schedule (every hour by default)

## Configuration

### Basic Setup

The default configuration backs up everything in `./data/source` to `./data/borg-repository`.

To customize what gets backed up, edit the auto-generated config:
```bash
./data/config/borgmatic/config.yaml
```

Then restart the container:
```bash
docker compose restart
```

### Setting a Secure Passphrase

For production use, set a secure passphrase:

1. Create a `.secrets` file (or copy from example):
   ```bash
   cp .secrets.example .secrets
   ```

2. Edit `.secrets` and change the passphrase:
   ```bash
   BORG_PASSPHRASE=your-very-secure-passphrase-here
   ```

3. Update docker-compose.yml to use the secrets file:
   ```yaml
   services:
     borgmatic:
       env_file:
         - .secrets
       # ... rest of config
   ```

### Backup Interval

Change the backup interval (in seconds) in docker-compose.yml:
```yaml
environment:
  - BACKUP_INTERVAL=1800  # 30 minutes
```

## Usage with Game Servers

### Example: Minecraft Server

```yaml
services:
  minecraft:
    image: itzg/minecraft-server
    container_name: minecraft
    environment:
      EULA: "TRUE"
    volumes:
      - ./data/source/minecraft:/data
    ports:
      - "25565:25565"

  borgmatic:
    build: https://github.com/AbbyNode/auto-borgmatic-docker.git
    container_name: borgmatic
    depends_on:
      - minecraft
    environment:
      - BACKUP_INTERVAL=3600
    env_file:
      - .secrets
    volumes:
      - ./data/source:/mnt/source:ro
      - ./data/borg-repository:/mnt/borg-repository
      - ./data/config/borgmatic:/etc/borgmatic.d
      - borgmatic-data:/root
    restart: unless-stopped

volumes:
  borgmatic-data:
```

The `depends_on` ensures Minecraft starts before backups begin.

## Restoring Backups

### List Available Backups
```bash
docker exec borgmatic borgmatic list
```

### Extract a Specific Backup
```bash
docker exec borgmatic borgmatic extract --archive backup-2025-11-06-120000
```

### Restore Latest Backup
```bash
docker exec borgmatic borgmatic extract --archive latest
```

For complete borgmatic documentation, see https://torsion.org/borgmatic/

## Remote Backups

To backup to a remote server via SSH:

1. Update the config file (`./data/config/borgmatic/config.yaml`):
   ```yaml
   repositories:
     - path: ssh://user@backup-server.com/path/to/repo
       label: remote-backup
   ```

2. Mount your SSH key in docker-compose.yml:
   ```yaml
   volumes:
     - ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro
   ```

3. Restart the container.

## Directory Structure

After first run:
```
.
├── docker-compose.yml
├── .secrets (optional, for custom passphrase)
└── data/
    ├── source/              # Your data to backup
    ├── borg-repository/     # Local borg storage
    └── config/
        └── borgmatic/
            └── config.yaml  # Auto-generated config
```

## Advanced Configuration

### Multiple Backup Sources

Edit `./data/config/borgmatic/config.yaml`:
```yaml
location:
  source_directories:
    - /mnt/source/world
    - /mnt/source/config
    - /mnt/source/plugins
```

### Exclude Patterns

```yaml
location:
  exclude_patterns:
    - '*.tmp'
    - '*/logs/*.log'
    - '*/cache'
```

### Retention Policy

```yaml
retention:
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 6
  keep_yearly: 1
```

## Manual Backup

Trigger a backup manually:
```bash
docker exec borgmatic /scripts/backup.sh
```

## Viewing Logs

```bash
docker logs borgmatic
```

For continuous monitoring:
```bash
docker logs -f borgmatic
```

## Stopping Backups

To temporarily stop backups:
```bash
docker compose stop borgmatic
```

To resume:
```bash
docker compose start borgmatic
```

## Security Notes

- The default passphrase is `change-me-in-production` - change this for any real use
- Store your passphrase securely - you need it to restore backups
- Backup sources are mounted read-only to prevent accidental modification
- For remote backups, ensure SSH keys are properly secured

## Troubleshooting

### Repository Already Exists Error

If you see "repository already exists", the borg repo is already initialized. This is normal.

### Permission Denied

Ensure the container has read access to source directories:
```bash
chmod -R 755 ./data/source
```

### Backup Not Running

Check the logs:
```bash
docker logs borgmatic
```

Verify the backup interval:
```bash
docker exec borgmatic env | grep BACKUP_INTERVAL
```
