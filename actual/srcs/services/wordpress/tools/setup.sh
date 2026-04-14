#!/bin/sh

WP_DIR=/var/www/html
WP="php -d memory_limit=512M /usr/local/bin/wp --allow-root"

mkdir -p ${WP_DIR}

# mariadb が起動するまで待機
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..."
    sleep 1
done

cd ${WP_DIR}

# WordPressがまだインストールされていない場合のみセットアップ
if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    echo "Downloading WordPress..."
    $WP core download

    $WP config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost=mariadb

    $WP core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    $WP user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=subscriber \
        --user_pass="${WP_USER_PASSWORD}"

    # Redis Object Cache の設定
    $WP config set WP_REDIS_HOST redis
    $WP config set WP_REDIS_PORT 6379 --raw
    $WP plugin install redis-cache --activate
    $WP redis enable

    echo "WordPress setup complete."
fi

chown -R nobody:nobody ${WP_DIR}

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
