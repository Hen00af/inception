FROM alpine:3.18

RUN apk add --no-cache vsftpd

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/setup.sh"]