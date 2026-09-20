# Alpineの1つ前の安定版あたりを指定 (最新=latestの禁止ルール対策)
FROM alpine:3.18

# パッケージの更新とMariaDBのインストール
RUN apk update && \
    apk add --no-cache mariadb mariadb-client curl unzip

# MySQLの実行に必要なディレクトリを作成し、権限を付与
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# 設定ファイルと起動スクリプトをコンテナ内にコピー
COPY ./conf/mariadb_server.conf /etc/my.cnf.d/mariadb-server.cnf
COPY ./tools/entrypoint.sh /usr/local/bin/

# スクリプトに実行権限を付与
RUN chmod +x /usr/local/bin/entrypoint.sh

# ポートの公開（ドキュメントとしての意味合いが強い）
EXPOSE 3306

# コンテナ起動時に実行されるコマンド
ENTRYPOINT ["entrypoint.sh"]

