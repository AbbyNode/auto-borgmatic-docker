# Auto Borgmatic Docker

Simple Docker setup for automated backups using Borgmatic and Ofelia.

## Quick Start

1. **Copy the secrets example file:**
   ```bash
   cp .secrets.example .secrets
   ```

2. **Edit `.secrets` and set a strong passphrase:**
   ```bash
   BORG_PASSPHRASE=your-strong-passphrase-here
   ```
   ⚠️ **Important:** Keep this passphrase safe - you need it to restore backups!

3. **Start the containers:**
   ```bash
   docker compose up -d
   ```

That's it! The setup will:
- Automatically create the `data/` and `borg-repository/` directories
- Initialize the Borg repository on first run
- Start running automated backups daily at 2 AM

4. **Optional - Test a manual backup:**
   ```bash
   docker exec borgmatic borgmatic --stats --verbosity 1
   ```

## How It Works

- **Borgmatic**: Runs backups using Borg backup tool
- **Ofelia**: Schedules automatic backups (default: daily at 2 AM)
- All data in `./data` directory is backed up to `./borg-repository`

## Configuration

### Backup Schedule

Edit the schedule in `docker-compose.yml`:
```yaml
ofelia.job-exec.borgmatic-backup.schedule: "0 2 * * *"  # Cron format
```

### Backup Settings

Edit `config.yaml` to customize:
- Source directories
- Retention policy (how many backups to keep)
- Compression settings
- Exclude patterns

### Add More Directories to Backup

1. Edit `docker-compose.yml` to add volume mounts:
   ```yaml
   volumes:
     - ./data:/mnt/source:ro
     - ./other-data:/mnt/other:ro  # Add this
   ```

2. Edit `config.yaml` to include the new directory:
   ```yaml
   source_directories:
     - /mnt/source
     - /mnt/other  # Add this
   ```

## Manual Operations

### Run backup manually:
```bash
docker exec borgmatic borgmatic --stats --verbosity 1
```

### List backups:
```bash
docker exec borgmatic borgmatic list
```

### Restore a backup:
```bash
docker exec borgmatic borgmatic extract --archive <archive-name> --destination /mnt/restore
```

### Check repository:
```bash
docker exec borgmatic borgmatic check --verbosity 1
```

## Logs

View Ofelia scheduler logs:
```bash
docker logs ofelia
```

View Borgmatic logs:
```bash
docker logs borgmatic
```
