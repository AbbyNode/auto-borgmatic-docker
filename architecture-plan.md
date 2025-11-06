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
│   ├── entrypoint.sh           # Container initialization & auto-config
│   └── backup.sh               # Backup execution logic
├── templates/
│   └── borgmatic-config.yaml   # Template for borgmatic config
└── data/                       # (User creates per-instance)
    ├── backups/
    │   └── borg-repository/    # Local borg repo (auto-initialized)
    ├── config/
    │   └── borgmatic/
    │       └── config.yaml     # Instance-specific config (auto-generated)
    └── game-server/            # Game data to backup
```

### Component Design

#### 1. Docker Image (Dockerfile)
**Base**: `ghcr.io/borgmatic-collective/borgmatic:latest`

**Additions**:
- Bash, curl, jq (already present)
- Auto-config generation script
- Enhanced `entrypoint.sh` - auto-initializes repo and config
- `backup.sh` - runs borgmatic with appropriate flags

**Purpose**: Provides automation without host-side scripting.

#### 2. Entrypoint Script Enhancement
**Current behavior**: 
- Creates config from template if missing
- Initializes repo if not present
- Keeps container running or executes command

**Proposed enhancements**:
- ✅ Keep current auto-init behavior for repository
- Auto-generate default config file if missing
- Read config from mounted directory
- Support remote repository setup from config

#### 3. Scheduled Backup Approach
**Approach**: Simple scheduled loop with compose dependency management

**Implementation**:
```bash
# In backup loop script
while true; do
    run_borgmatic_backup
    sleep $BACKUP_INTERVAL
done
```

**Scheduling Control**:
- Use compose `depends_on` to ensure game server starts before borgmatic
- Backups run on schedule while container is running
- User can stop borgmatic container when not needed

#### 4. Per-Instance Configuration
**Configuration File** (auto-generated on first run):
```yaml
# /mnt/config/borgmatic.conf (or similar)
# Repository settings
repository: /mnt/borg-repository  # or ssh://user@host/path
encryption: repokey-blake2

# Backup sources
backup_sources:
  - /mnt/source/world
  - /mnt/source/config
  - /mnt/source/mods

# Scheduling
backup_interval: 3600  # seconds (1 hour)
```

**Secrets** (in .secrets file, not committed):
```bash
BORG_PASSPHRASE=secure-passphrase
```

**Note**: Configuration is stored in bind-mounted directory for easy editing and persistence.

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
- [ ] Auto-generate default config on first run
- [ ] Support config file for:
  - Custom encryption method
  - Remote repository paths
  - SSH key handling for remote repos

### Phase 2: Scheduled Backup with depends_on
- [ ] Create backup scheduler script
  - Loop with interval from config file
  - Run backups on schedule
- [ ] Use compose `depends_on` to ensure game server starts first
- [ ] Container runs continuously for scheduled backups

### Phase 3: Remote Repository Support
- [ ] Enhance entrypoint to detect remote repo format
- [ ] Auto-initialize remote repos if needed
- [ ] SSH key management (mount from secrets)
- [ ] Test with remote SSH target

### Phase 4: Documentation
- [ ] README with setup instructions
- [ ] Example docker-compose.yml for easy setup
- [ ] Brief instructions on running borgmatic commands in container

## Usage Pattern

### Setup New Game Server Instance
1. Create directory structure:
   ```bash
   mkdir -p data/backups/borg-repository
   mkdir -p data/config/borgmatic
   ```

2. Create `.secrets` file
   ```bash
   BORG_PASSPHRASE=unique-secure-passphrase
   ```

3. Start containers (config auto-generated on first run):
   ```bash
   docker compose up -d
   ```

4. Repository auto-initializes on first run
5. Backups run automatically on schedule
6. (Optional) Edit `/data/config/borgmatic/config.yaml` to customize settings

### Running Borgmatic Commands
Use `docker exec` to run borgmatic commands in the container:
```bash
# List archives
docker exec borgmatic-minecraft borgmatic list

# Extract specific archive
docker exec borgmatic-minecraft borgmatic extract --archive minecraft-2025-11-06-120000
```

For complete borgmatic documentation, see https://torsion.org/borgmatic/

## Design Decisions & Rationale

### Why Custom Dockerfile?
- **Required** to include automation scripts inside container
- Avoids host-side script execution (violates constraints)
- Based on official borgmatic image (follows guidelines)
- Minimal additions (bash, auto-config generation)

### Why Config File Instead of Environment Variables?
- More flexible for complex configurations
- Easier to edit and maintain
- Bind-mounted directory allows direct file editing
- Supports all borgmatic configuration options
- Clear separation from secrets

### Why depends_on for Scheduling?
- Simple and built into Docker Compose
- No need for Docker socket access
- Game server starts before borgmatic automatically
- User controls backup timing by starting/stopping borgmatic container

### Why Keep Container Running?
- Allows scheduled backups via internal loop
- Enables `docker exec` for manual operations and restore
- Consistent with game server container pattern
- No external cron needed (host-side execution avoided)

## Security Considerations

1. **Encryption**: Using repokey-blake2 by default (secure, key in repo)
2. **Secrets**: Passphrase in `.secrets` file (not committed)
3. **SSH Keys**: Mounted from host secrets directory if remote backup
4. **Backup Sources**: Mounted read-only to prevent accidental modification

## Limitations & Assumptions

1. **Same Docker Host**: Game server and borgmatic must be on same Docker host
   - Remote borg repositories supported for backup storage
2. **Single Game Server**: Each borgmatic instance backs up one game server
   - Multiple game servers need multiple borgmatic instances
3. **Linux Host**: Scripts use Linux commands (standard for Docker)

## Future Enhancements (Out of Scope)

- Integration with cloud storage (S3, B2, etc.)
