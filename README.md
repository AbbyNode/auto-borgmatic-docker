# Auto-Borgmatic Docker

Automated borgmatic backups with zero-config setup.

## Quick Start

```bash
docker compose up -d
```

Everything auto-initializes: directories, config, and borg repository.

## Configuration

Backups run hourly by default. To customize:

1. Edit `./data/config/borgmatic/crontab.txt` for schedule
2. Edit `./data/config/borgmatic/config.yaml` for backup settings
3. Restart: `docker compose restart`

## Set Passphrase

For production:

```bash
echo "BORG_PASSPHRASE=your-secure-passphrase" > .secrets
docker compose up -d
```

## Restore

```bash
docker exec borgmatic borgmatic list
docker exec borgmatic borgmatic extract --archive latest
```

See https://torsion.org/borgmatic/ for complete borgmatic documentation.

## Remote Backups

Update `./data/config/borgmatic/config.yaml`:

```yaml
repositories:
  - path: ssh://user@host/path/to/repo
```

Mount SSH key in docker-compose.yml:

```yaml
volumes:
  - ~/.ssh/id_rsa:/root/.ssh/id_rsa:ro
```
