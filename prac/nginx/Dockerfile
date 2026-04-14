FROM alpine:3.18

RUN apk update && apk add --no-cache nginx openssl

EXPOSE 443

COPY ./html usr/share/nginx/html

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]


