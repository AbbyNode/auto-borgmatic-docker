# Architecture Plan: Auto-Borgmatic for Game Servers

## User Requirements

### Primary Goal
Automated borgmatic backups for game servers with minimal manual intervention. Each game server instance gets its own borg repository with automated initialization and scheduled backups.

### Key Requirements

1. **Per-Instance Borg Repositories**
   - Each game server/world gets a new borg repository
   - Auto-initialization with consistent settings
   - No manual setup required beyond specifying backup directories

2. **Security & Remote Support**
   - Local repos can use simple encryption (repokey)
   - Support for remote hosts per instance
   - Handle new remote repos that don't exist yet

3. **Automated Backup Scheduling**
   - Run on regular intervals while game server is running
   - Only backup when associated containers are active
   - Pause when game server stops

4. **Easy Restoration**
   - Use standard borgmatic commands for restore
   - Direct container access for restore operations

5. **Implementation Constraints**
   - ✅ Prefer official images
   - ✅ Custom Dockerfile acceptable if needed for automation
   - ❌ No code execution in compose files
   - ❌ No code execution on host machine
   - ✅ All scripts run inside containers

## Proposed Architecture

### Directory Structure
```
/home/runner/work/auto-borgmatic-docker/auto-borgmatic-docker/
├── docker-compose.yml           # Main compose for borgmatic service
├── Dockerfile                   # Custom image with automation scripts
├── scripts/
│   ├── entrypoint.sh           # Container initialization
│   ├── backup.sh               # Backup execution logic
│   └── wait-for-container.sh   # (NEW) Monitor game server container
├── templates/
│   └── borgmatic-config.yaml   # Template for borgmatic config
└── data/                       # (User creates per-instance)
    ├── backups/
    │   └── borg-repository/    # Local borg repo (auto-initialized)
    ├── config/
    │   └── borgmatic/
    │       └── config.yaml     # Instance-specific config
    └── game-server/            # Game data to backup
```

### Component Design

#### 1. Docker Image (Dockerfile)
**Base**: `ghcr.io/borgmatic-collective/borgmatic:latest`

**Additions**:
- Bash, curl, jq (already present)
- `wait-for-container.sh` - monitors game server container state
- Enhanced `entrypoint.sh` - auto-initializes repo if missing
- `backup.sh` - runs borgmatic with appropriate flags

**Purpose**: Provides automation without host-side scripting.

#### 2. Entrypoint Script Enhancement
**Current behavior**: 
- Creates config from template if missing
- Initializes repo if not present
- Keeps container running or executes command

**Proposed enhancements**:
- ✅ Keep current auto-init behavior
- ✅ Support env vars for repository location (local vs remote)
- ✅ Support env vars for encryption mode
- Add remote repository setup if specified

#### 3. Conditional Backup Scheduling
**Approach**: Container monitor + cron/sleep loop

**Options evaluated**:
- Option A: Use `wait-for-container.sh` in loop that checks if game container is running
- Option B: Docker healthcheck + restart policy
- **Recommended: Option A** - More explicit control

**Implementation**:
```bash
# In backup loop script
while true; do
    if container_is_running "$GAME_CONTAINER_NAME"; then
        run_borgmatic_backup
    fi
    sleep $BACKUP_INTERVAL
done
```

#### 4. Per-Instance Configuration
**Environment Variables** (in .env):
```bash
# Repository settings
BORG_REPO_PATH=/mnt/borg-repository    # or ssh://user@host/path
BORG_PASSPHRASE=secure-passphrase
BORG_ENCRYPTION=repokey-blake2

# Backup sources (comma-separated)
BACKUP_SOURCES=/mnt/source/world,/mnt/source/config,/mnt/source/mods

# Scheduling
BACKUP_INTERVAL=3600  # seconds (1 hour)
GAME_CONTAINER_NAME=minecraft-server

# Remote setup (optional)
REMOTE_HOST=user@backup-server.com
REMOTE_PATH=/backups/minecraft-world1
SSH_KEY_PATH=/root/.ssh/id_borgmatic
```

**Borgmatic Config Template**:
- Use environment variable substitution
- Source directories from `BACKUP_SOURCES`
- Repository path from `BORG_REPO_PATH`

#### 5. Container Dependencies
**docker-compose.yml structure**:
```yaml
services:
  game-server:
    # User's game server definition
    container_name: minecraft-server
    # ...

  borgmatic:
    image: eclarift/borgmatic:latest
    container_name: borgmatic-minecraft
    depends_on:
      - game-server
    env_file:
      - .env
      - .secrets
    volumes:
      - ./data/game-server:/mnt/source:ro
      - ./data/backups/borg-repository:/mnt/borg-repository
      - ./data/config/borgmatic:/etc/borgmatic.d
      - borgmatic-data:/root
    # No command - entrypoint handles everything
```

## Implementation Steps

### Phase 1: Core Auto-Initialization
- [x] Current repo init in entrypoint works
- [ ] Add environment variable support for:
  - Custom encryption method
  - Remote repository paths
  - SSH key handling for remote repos

### Phase 2: Conditional Backup Scheduling
- [ ] Create `wait-for-container.sh` script
  - Check if named container is running via Docker socket
  - Handle container not found gracefully
- [ ] Create backup scheduler script
  - Loop with interval from env var
  - Check container state before backup
  - Execute backup only when game server running
- [ ] Mount Docker socket to borgmatic container (read-only)
  - Required for container monitoring
  - Security consideration documented

### Phase 3: Remote Repository Support
- [ ] Enhance entrypoint to detect remote repo format
- [ ] Auto-initialize remote repos if needed
- [ ] SSH key management (mount from secrets)
- [ ] Test with remote SSH target

### Phase 4: Documentation
- [ ] README with setup instructions
- [ ] Example .env configurations
  - Local-only setup
  - Remote repository setup
  - Multiple game servers
- [ ] Restore procedure documentation

## Usage Pattern

### Setup New Game Server Instance
1. Create directory structure:
   ```bash
   mkdir -p data/backups/borg-repository
   mkdir -p data/config/borgmatic
   ```

2. Create `.env` file with instance-specific settings
   ```bash
   BACKUP_SOURCES=/mnt/source/world
   GAME_CONTAINER_NAME=minecraft-server
   BACKUP_INTERVAL=3600
   ```

3. Create `.secrets` file
   ```bash
   BORG_PASSPHRASE=unique-secure-passphrase
   ```

4. Start containers:
   ```bash
   docker compose up -d
   ```

5. Repository auto-initializes on first run
6. Backups run automatically every hour while game server is running

### Restore Data
```bash
# List archives
docker exec borgmatic-minecraft borgmatic list

# Extract specific archive
docker exec borgmatic-minecraft borgmatic extract --archive minecraft-2025-11-06-120000

# Restore to original location
docker exec borgmatic-minecraft borgmatic restore --archive latest
```

## Design Decisions & Rationale

### Why Custom Dockerfile?
- **Required** to include automation scripts inside container
- Avoids host-side script execution (violates constraints)
- Based on official borgmatic image (follows guidelines)
- Minimal additions (bash, monitoring scripts)

### Why Docker Socket Access?
- **Required** to monitor game server container state
- Read-only mount minimizes security risk
- Alternative would be external orchestrator (more complex)
- User can disable if running backup continuously without conditions

### Why Environment Variables for Config?
- Per-instance customization without code changes
- Standard Docker pattern
- Easy to version control (except secrets)
- Clear separation of instance-specific data

### Why Keep Container Running?
- Allows scheduled backups via internal cron/loop
- Enables `docker exec` for manual operations and restore
- Consistent with game server container pattern
- No external cron needed (host-side execution avoided)

## Security Considerations

1. **Encryption**: Using repokey-blake2 by default (secure, key in repo)
2. **Secrets**: Passphrase in `.secrets` file (not committed)
3. **Docker Socket**: Read-only access for monitoring only
4. **SSH Keys**: Mounted from host secrets directory if remote backup
5. **Backup Sources**: Mounted read-only to prevent accidental modification

## Limitations & Assumptions

1. **Docker Socket**: Requires Docker socket access for container monitoring
   - Can be disabled if user runs backups on fixed schedule
2. **Same Docker Network**: Game server and borgmatic must be on same Docker host
   - Remote backups supported, remote game servers not monitored
3. **Single Game Server**: Each borgmatic instance monitors one game container
   - Multiple game servers need multiple borgmatic instances
4. **Linux Host**: Scripts use Linux commands (standard for Docker)

## Future Enhancements (Out of Scope)

- Web UI for backup management
- Automatic backup verification
- Multi-container monitoring (backup when any of N containers running)
- Backup rotation alerts/notifications
- Backup size monitoring and cleanup
- Integration with cloud storage (S3, B2, etc.)
