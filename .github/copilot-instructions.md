# Copilot Instructions

## Workflow

### Developer
Developers use `build.compose.yml` to build and push Docker images:
```bash
docker compose -f build.compose.yml build
docker compose -f build.compose.yml push
```

### End User
End users only need the single `docker-compose.yml` file. They don't clone the repository:
```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
docker compose pull
docker compose up -d
```

## Style

### Documentation

* Keep documentation concise and actionable.
* Do not document obvious things. Focus on how to run and use features.
* Only document non-obvious implementation details if important.
* Never include things like a generic "Features" or "Benefits" section which only restates known information.

### Commits
* When creating new commits in automatic agent mode, always prefix commit with `[COPILOT]`.
## Design Principles

### Docker Images
* Prefer official Docker images when functionality can be achieved easily.
* Create custom images only when necessary for specific functionality.

### Code Execution
* **Never** run scripts or bash code on the host machine.
    * All scripts must run inside containers.
* **Never** put code execution logic in compose files.
* **Never** bind mount files directly. Bind mounts should only be used for directories.
    * Use `ln` inside containers to isolate files into bound directories.

### Cohesion with Existing Modules
* New work should be cohesive with existing modules.
* Refer to the same game files when possible.
* Use similar approaches to existing implementations.
