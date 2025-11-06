---
applyTo: "**/Dockerfile,**/Containerfile,**/docker-compose.yml,**/*.compose.yml"
---

# Docker Guidelines

* Prefer official Docker images when functionality can be achieved easily with them.
* Create custom images only when necessary for specific custom functionality.
* Never put code execution logic directly in compose files.
* Never bind mount files directly as this interferes with first time creation.
    * Bind mounts should only be used for directories.
    * Use `ln` inside containers to isolate to-be-bound files into bound directories.
