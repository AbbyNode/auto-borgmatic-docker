
# Mapping of binds in host and containers

| Host                      | Minecraft | Borgmatic | MCASelector | Ofelia |
|---------------------------|-----------|-----------|-------------|--------|
| `./data/backups`          | N/A       | `/mnt/borg-repository` | N/A | N/A |
| `./data/config/borgmatic` | N/A       | `/etc/borgmatic.d` | N/A         | N/A    |
| `./data/config`           | `/config` | N/A       | `/config`   | N/A    |
| `./data/config/ofelia`    | N/A       | N/A       | N/A         | `/config` |
| `./data/setup-scripts/ofelia-entrypoint.sh` | N/A | N/A | N/A | `/setup-scripts/ofelia-entrypoint.sh` |

