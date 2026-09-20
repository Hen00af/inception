#!/bin/sh

# データベースの初期化がまだ行われていない場合のみ実行
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    
    # DBの初期インストール
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # バックグラウンドで一時的にMariaDBを起動
    /usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql &
    sleep 3 # 起動待ち

    echo "Creating database and users..."
    
    # データベースとユーザーの作成、権限付与
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    
    # rootパスワードの設定
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

    # 一時起動したMariaDBをシャットダウン
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    sleep 2
fi

echo "Starting MariaDB in foreground..."
# "exec" を使うことで、mysqldがPID 1を引き継ぎ、安全にコンテナを終了できるようにする
exec /usr/bin/mysqld --user=mysql --console