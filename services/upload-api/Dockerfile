FROM alpine:3.18
RUN apk add --no-cache python3
COPY ./app.py /app/app.py
EXPOSE 8000
CMD ["python3", "/app/app.py"]
