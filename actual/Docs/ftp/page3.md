# vsftpd とは何か

## vsftpd の概要

**vsftpd（Very Secure FTP Daemon）** は Linux で最もよく使われる FTP サーバーソフト。

- Very Secure = セキュリティを重視して設計されている
- Daemon = バックグラウンドで常駐して動き続けるプロセス

Alpine Linux のパッケージとして提供されているので、Dockerfile に 1 行書くだけでインストールできる。

## Dockerfile の構成

```dockerfile
FROM alpine:3.18

RUN apk update && \
    apk add --no-cache vsftpd

# 設定ファイルをコンテナ内にコピー
COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

# FTP ユーザーを作成（パスワードは環境変数から渡す）
COPY ./tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["setup.sh"]
```

## Docker 構成の中での役割

```
docker network (inception_net)
┌──────────────────────────────────────────┐
│                                          │
│  [mariadb]  [wordpress]  [nginx]         │
│                  ↕ 同じボリューム共有     │
│             [ftp コンテナ]               │
│                                          │
└──────────────────────────────────────────┘
         ↕ ポート 21, 21100-21110
    自分の PC（FileZilla などで接続）
```

FTP コンテナは **インターネット（外部）からの唯一のファイル操作窓口** になる。

## なぜ setup.sh が必要か

FTP ユーザーのパスワードは `.env` ファイルから環境変数として渡す。
Dockerfile に直接パスワードを書くことは禁止されているので、起動時に setup.sh の中で動的にユーザーを作成する。

```sh
#!/bin/sh

# 環境変数からユーザーを作成
adduser -h /var/www/html -s /sbin/nologin -D ${FTP_USER}
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# vsftpd を起動（exec でPID 1 を引き継ぐ）
exec vsftpd /etc/vsftpd/vsftpd.conf
```

`exec` を使う理由は MariaDB や WordPress と同じ：PID 1 を vsftpd に引き継がせることで、
Docker の停止シグナル（SIGTERM）を正しく受け取れるようにするため。
