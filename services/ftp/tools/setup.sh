#!/bin/sh
set -eu

: "${FTP_USER:?FTP_USER must be set}"
: "${FTP_PASSWORD:?FTP_PASSWORD must be set}"

if ! id "$FTP_USER" >/dev/null 2>&1; then
    adduser -D -h /var/www/html -s /sbin/nologin "$FTP_USER"
fi

printf '%s:%s\n' "$FTP_USER" "$FTP_PASSWORD" | chpasswd

exec vsftpd /etc/vsftpd/vsftpd.conf
