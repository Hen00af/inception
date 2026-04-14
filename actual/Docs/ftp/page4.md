# vsftpd 設定ファイルと起動確認

## vsftpd.conf の主要な設定項目

```ini
# ローカルユーザー（Linux ユーザー）でのログインを許可
local_enable=YES

# ファイルのアップロードを許可
write_enable=YES

# anonymous（匿名）ログインを禁止
anonymous_enable=NO

# パッシブモードを有効化
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110

# パッシブモード時にクライアントへ返す IP（Docker ホストの IP）
# localhost の場合は 127.0.0.1
pasv_address=127.0.0.1

# chroot: ユーザーを自分のホームディレクトリより上に出られないようにする
chroot_local_user=YES
allow_writeable_chroot=YES

# ログの出力
xferlog_enable=YES
```

### 設定の意味まとめ

| 設定 | 意味 |
|------|------|
| `local_enable=YES` | Linux のユーザーアカウントでログインできる |
| `write_enable=YES` | アップロード・削除などの書き込み操作を許可 |
| `anonymous_enable=NO` | 認証なしの接続を禁止（セキュリティ） |
| `pasv_enable=YES` | パッシブモードを使う |
| `chroot_local_user=YES` | ユーザーを自分のフォルダより上に移動できないよう制限 |

## docker-compose.yml への追加

```yaml
ftp:
  container_name: ftp
  build: ./srcs/services/ftp
  restart: always
  env_file: .env
  ports:
    - "21:21"
    - "21100-21110:21100-21110"
  volumes:
    - wordpress_data:/var/www/html
  networks:
    - inception_net
```

ポイント：
- `wordpress_data` ボリュームを WordPress と共有してファイルを共有する
- パッシブモード用のポート範囲（21100-21110）を公開する

## 起動確認の手順

### 1. コンテナが動いているか確認

```sh
docker compose ps
```

ftp コンテナの STATUS が `Up` になっていれば OK。

### 2. FTP 接続テスト（コマンドラインで）

```sh
ftp localhost 21
# または
curl -v ftp://localhost --user "ユーザー名:パスワード"
```

### 3. FileZilla で接続する場合

| 項目 | 値 |
|------|----|
| ホスト | 127.0.0.1 |
| ユーザー名 | `.env` の FTP_USER |
| パスワード | `.env` の FTP_PASSWORD |
| ポート | 21 |
| 接続方法 | FTP（明示的な TLS なし） |

接続後、WordPress のファイル（wp-content/themes など）が見えれば成功。

## よくあるエラー

| エラー | 原因 | 解決策 |
|--------|------|--------|
| 500 OOPS: vsftpd: refusing to run with writable root inside chroot | chroot とディレクトリの権限の競合 | `allow_writeable_chroot=YES` を設定 |
| 227 Entering Passive Mode でタイムアウト | pasv_address が間違っている | `pasv_address=127.0.0.1` に修正 |
| 530 Login incorrect | ユーザー作成が失敗している | setup.sh のユーザー作成ログを確認 |
