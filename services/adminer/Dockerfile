FROM alpine:3.18

RUN apk add --no-cache \
    php82 \
    php82-session \
    php82-mysqli \
    php82-pdo_mysql \
    php82-openssl \
    php82-mbstring \
    php82-json \
    curl

RUN mkdir -p /var/www/html \
    && curl -L https://www.adminer.org/latest.php \
    -o /var/www/html/index.php

WORKDIR /var/www/html

EXPOSE 8080

CMD ["php82", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
