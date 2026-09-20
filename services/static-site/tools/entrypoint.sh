#!/bin/sh
set -eu

mkdir -p /var/www/static
if [ ! -f /var/www/static/index.html ]; then
    cp -a /usr/share/static-template/. /var/www/static/
fi
chmod -R a+rwX /var/www/static

exec "$@"
