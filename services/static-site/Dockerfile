FROM alpine:3.18
RUN apk add --no-cache nginx
COPY ./index.html ./style.css ./script.js /usr/share/static-template/
COPY ./nginx.conf /etc/nginx/http.d/default.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
