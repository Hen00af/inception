#!/bin/sh
set -eu

WP_DIR=/var/www/html
WP="php -d memory_limit=512M /usr/local/bin/wp --allow-root"

mkdir -p "${WP_DIR}"

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..."
    sleep 1
done

cd "${WP_DIR}"

if [ ! -f "${WP_DIR}/wp-load.php" ]; then
    echo "Downloading WordPress..."
    $WP core download
fi

if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    $WP config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb
fi

if ! $WP core is-installed; then
    echo "Installing WordPress..."
    $WP core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    if ! $WP user get "${WP_USER}" --field=ID >/dev/null 2>&1; then
        $WP user create "${WP_USER}" "${WP_USER_EMAIL}" \
            --role=subscriber \
            --user_pass="${WP_USER_PASSWORD}"
    fi
fi

if ! $WP plugin is-installed redis-cache; then
    $WP plugin install redis-cache --activate
fi

chown -R nobody:nobody "${WP_DIR}"

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
