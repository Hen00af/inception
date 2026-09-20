# Inception — Developer documentation

## Project layout

The repository-level documentation lives alongside this file. The runnable
Docker Compose project is in `actual/`:

```text
actual/
├── Makefile
├── docker-compose.yml
├── .env.example
└── srcs/services/
    ├── marinadb/     MariaDB image and initialization script
    ├── nginx/        HTTPS reverse-proxy image and configuration
    ├── redis/        Redis image
    └── wordpress/    PHP-FPM image and WordPress setup script
```

## Set up from scratch

### Prerequisites

Install and run Docker Engine with the Docker Compose v2 plugin. You also need
GNU Make, a shell, permission to run Docker commands, and permission to bind
host port 443. A browser is useful for checking the site.

Ensure the configured domain resolves to this Docker host. For local use, add
the following to `/etc/hosts` (replace the name if `DOMAIN_NAME` differs):

```text
127.0.0.1 shattori.42.fr
```

### Configuration and secrets

Create the ignored runtime configuration from its template:

```sh
cd actual
cp .env.example .env
```

Edit `actual/.env` before the first launch. Replace all
`change_this_*` placeholders and set `DOMAIN_NAME` to the domain that will
reach this host. The file contains these groups of settings:

- `MYSQL_*`: database name, application account, and MariaDB root password.
- `WP_ADMIN_*`: initial WordPress administrator account.
- `WP_USER*`: initial subscriber account.
- `DOMAIN_NAME`: WordPress URL and NGINX server name.

Never commit `.env` or copy it into documentation, issues, or logs. Commit
only changes to `.env.example` that are safe placeholders.

## Build and launch

Run Make from `actual/`:

```sh
make          # same as `make up`: create data directories, build, and start
make up       # build images and start services in the background
make down     # stop/remove containers; preserve images and persistent data
make clean    # remove containers and network; preserve images and data
make fclean   # remove containers, images, volumes, and persisted data
make re       # fclean followed by a clean build and start
```

`make fclean` is destructive: it removes both the MariaDB database and the
WordPress files. Use it only when a full reset is intended.

The Makefile exports `DATA_PATH=$(HOME)/data`; Compose uses it to mount the
two persistent volumes. To use a different location for a Make invocation,
pass it explicitly, for example `make DATA_PATH=/srv/inception-data up`.

## Docker Compose management

All Compose commands below are run from `actual/`:

```sh
docker compose ps                         # service and health/status overview
docker compose logs -f wordpress          # follow one service's logs
docker compose logs --tail=100             # recent logs from all services
docker compose up -d --build nginx         # rebuild/restart one service
docker compose restart wordpress           # restart one running service
docker compose exec wordpress sh           # shell inside the WordPress container
docker compose exec mariadb sh             # shell inside the MariaDB container
docker compose down                        # stop services, retain data
docker compose down -v                     # remove Compose volume definitions too
```

The defined services are `nginx`, `wordpress`, `mariadb`, and `redis`.
NGINX is the only host-facing service (`443:443`); the other services
communicate over the private `inception_net` bridge network.

## Data locations and persistence

Compose defines named local volumes backed by host directories:

| Docker volume | Host path | Container path | Contents |
| --- | --- | --- | --- |
| `mariadb_data` | `~/data/mariadb` | `/var/lib/mysql` | MariaDB databases and accounts. |
| `wordpress_data` | `~/data/wordpress` | `/var/www/html` | WordPress core files, configuration, themes, plugins, and uploads. |

These directories are created by `make up` before Compose starts. They survive
container removal, `make down`, and `make clean`, so WordPress setup scripts
do not reinitialize existing data. Redis has no mounted volume and its cache
is intentionally ephemeral.

Inspect the host data without entering a container:

```sh
ls -la "$HOME/data/mariadb"
ls -la "$HOME/data/wordpress"
docker volume ls                            # find the Compose-prefixed volume names
```

For a reset, use `make fclean`; it removes the Docker resources and these two
host data directories. Back up both directories before resetting a live site.
