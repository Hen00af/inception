# mariadbdとmariadbの違い
mariadb主に２つのコンポーネントにわかれている
1. mariadbd... maria DBにおいて実際のDATAが格納されるDB本体。
2. mariadb ... maria DBにおいて、DB側に格納されているDATAをとってくるエージェント
コマンドで説明すると以下のとおりである。

## mariadbd
Dockerfileを確認すると
```sh
	apt-get install -y mariadb-client mariadb-server
```
と２つのバイナリをインストールしているのが確認できるはずあり、実際にentrypointでも
```sh
	RUN exec /usr/bin/mysqld --user=mysql --console
```
とDBが実行されているはずである。
これはフォアグラウンドでDBを動かしている。

## mariadb
my-sqlを手動で動かす際に使用するDBドライバーである。
APIや今回はphp-mysqlというドライバーをphp側から使用してDBの取得、変更、削除を行うのでテスト段階以外は使用しない。

