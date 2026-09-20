# Inception — User documentation

This project runs a small WordPress website behind an HTTPS web server. It is
intended to be operated from the `actual/` directory of this repository.

## Services provided

| Service | Purpose | Directly accessible? |
| --- | --- | --- |
| NGINX | Serves the WordPress site over HTTPS on port 443. | Yes, in a browser. |
| WordPress + PHP-FPM | Provides the website and its administration interface. | Through NGINX only. |
| MariaDB | Stores WordPress content, users, and settings. | Internal network only. |
| Redis | Caches WordPress objects to improve response time. | Internal network only. |

The public entry point is `https://shattori.42.fr`. The TLS certificate is
self-signed, so the browser will show a certificate warning; accept the
warning only when using this local development stack.

## Start and stop the project

Run these commands from the repository root:

```sh
cd actual
make
```

`make` builds the images if needed, creates the persistent data directories,
and starts all services in the background. To stop the services while keeping
their data, run:

```sh
cd actual
make down
```

To start them again, use `make`.

## Access the site and administration panel

The configured site name is read from `DOMAIN_NAME` in `actual/.env` (the
sample configuration uses `shattori.42.fr`). Make that name resolve to the
machine that runs Docker. For a local installation, add this line to the host
machine's `/etc/hosts` file:

```text
127.0.0.1 shattori.42.fr
```

Then visit:

- Website: `https://shattori.42.fr`
- WordPress administration: `https://shattori.42.fr/wp-admin`

Sign in to the administration panel with the username and password held in
`WP_ADMIN_USER` and `WP_ADMIN_PASSWORD` in `actual/.env`.

## Credentials

Credentials and site settings are stored in `actual/.env`. This file is not
committed to Git. Its safe-to-share template is `actual/.env.example`.

Before the first start, copy the template and replace every
`change_this_*` value with a strong, unique secret:

```sh
cd actual
cp .env.example .env
```

The relevant variables are:

| Variables | Used for |
| --- | --- |
| `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL` | WordPress administrator login. |
| `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL` | Initial non-administrator WordPress user. |
| `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD` | WordPress database connection. |
| `MYSQL_ROOT_PASSWORD` | MariaDB root account; normally needed only for database maintenance. |
| `DOMAIN_NAME` | Address used by WordPress and NGINX. |

Keep `.env` private. Changing initial credentials after the stack has already
been initialized does not automatically change the existing WordPress or
MariaDB accounts; change those accounts through WordPress or MariaDB instead.

## Check that services are working

From `actual/`, confirm that all four services show `running`:

```sh
docker compose ps
```

View recent service output when diagnosing a problem:

```sh
docker compose logs --tail=100 nginx wordpress mariadb redis
```

Finally, load the website and `/wp-admin` in a browser. A working site proves
that NGINX can reach WordPress, and WordPress can reach MariaDB. If the site
does not open, first check that Docker is running, that port 443 is available,
and that `DOMAIN_NAME` resolves to the Docker host.
