FROM alpine:3.18

RUN apk update && \
    apk add --no-cache \
        php82 \
        php82-fpm \
        php82-mysqli \
        php82-json \
        php82-curl \
        php82-dom \
        php82-exif \
        php82-fileinfo \
        php82-mbstring \
        php82-openssl \
        php82-xml \
        php82-zip \
        php82-phar \
        php82-iconv \
        php82-gd \
        php82-pecl-redis \
        mariadb-client \
        wget

RUN ln -sf /usr/bin/php82 /usr/bin/php

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

ENTRYPOINT ["setup.sh"]
