# Copilot Instructions

## Documentation Style

* Keep documentation concise.
* Do not document obvious things.
* Keep documentation concise and actionable.
* Focus on how to run and use features.
* Only document non-obvious implementation details if important.

## Workflow

### Developer Workflow
Developers use `build.compose.yml` to build and push Docker images:
```bash
docker compose -f build.compose.yml build
docker compose -f build.compose.yml push
```

### User Workflow
End users only need the single `docker-compose.yml` file. They don't clone the repository:
```bash
curl -O https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/docker-compose.yml
curl -o .env https://raw.githubusercontent.com/AbbyNode/minecraft-modpack-docker/main/.env.example
docker compose pull
docker compose up -d
```

## Design Principles

### Custom Docker Images
* Prefer official Docker images when functionality can be achieved easily.
* Create custom images only when necessary for specific functionality.

### Code Execution
* **Never** run scripts or bash code on the host machine.
* **Never** put code execution logic in compose files.
* All scripts must run inside containers.
* Containers may mount the working directory if needed for their operation.

### Cohesion with Existing Modules
* New work should be cohesive with existing modules.
* Refer to the same game files when possible.
* Use similar approaches to existing implementations.
