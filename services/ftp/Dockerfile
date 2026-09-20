FROM alpine:3.18

RUN apk add --no-cache vsftpd \
    && mkdir -p /var/run/vsftpd/empty \
    && chown root:root /var/run/vsftpd /var/run/vsftpd/empty \
    && chmod 755 /var/run/vsftpd /var/run/vsftpd/empty

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/setup.sh"]