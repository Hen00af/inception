# 42 Inception - 1Day RTA 攻略＆要件まとめ

## 1. 必須要件 (Mandatory)
[cite_start]プロジェクト全体は仮想マシン上で実施し、`docker-compose`を使用すること [cite: 63]。

### 基本ルール
- [cite_start]各サービスは専用のコンテナで実行し、サービスと同じ名前にする [cite: 64, 65]。
- [cite_start]コンテナはAlpineまたはDebianの安定版から2つ前のバージョンを使用 [cite: 66]。
- [cite_start]既製のDockerイメージのPullは禁止（OS除く）。各サービスごとに独自の `Dockerfile` を作成し、Makefileからビルドする [cite: 67, 68]。
- [cite_start]コンテナはクラッシュ時に再起動すること [cite: 76]。
- [cite_start]ドメイン名 `login.42.fr`（例: `hattori.42.fr`）がローカルIPを指すように設定する [cite: 86, 87, 88]。

### 構築する3つのコンテナ
1. [cite_start]**NGINX:** TLSv1.2 または TLSv1.3 のみを使用。ポート443経由でのインフラへの唯一のエントリポイント [cite: 70, 96]。
2. [cite_start]**WordPress + php-fpm:** NGINXを含まない。DBに管理者を含む2名のユーザーを作成（管理者の名前に `admin` 等を含むのは禁止） [cite: 71, 84]。
3. [cite_start]**MariaDB:** NGINXを含まないDB単独コンテナ [cite: 72]。

### ボリュームとネットワーク
- [cite_start]ホスト側の `/home/login/data` 以下にマウントする [cite: 85]。
  - [cite_start]WordPressデータベース用のボリューム [cite: 73]。
  - [cite_start]WordPressウェブサイトファイル用のボリューム [cite: 74]。
- [cite_start]コンテナ間を接続するDockerネットワークを構築する [cite: 75]。

---

## 2. セキュリティ・禁止事項 (一発アウト対策)
以下のルールを破ると評価時に不合格となるため徹底すること。
- [cite_start]`latest` タグの使用禁止 [cite: 90]。
- [cite_start]`network: host`、`--link`、`links:` の使用禁止 [cite: 82]。
- [cite_start]`tail -f`、`bash`、`sleep infinity` などのハック的な無限ループコマンドの使用禁止 [cite: 78, 82]。
- [cite_start]Dockerfile内へのパスワード直書き禁止。環境変数の保存には `.env` を使用すること [cite: 91, 92, 93]。
- [cite_start]認証情報（APIキー、パスワード）をGitリポジトリに保存しないこと [cite: 94, 95]。

---

## 3. ボーナス要件 (Bonus)
[cite_start]**※必須部分が完全に機能している場合のみ評価される [cite: 206]。**
[cite_start]追加サービスごとに専用のDockerfileを作成すること [cite: 197]。

- [ ] [cite_start]**Redisキャッシュ:** WordPressサイトのキャッシュ管理 [cite: 199]。
- [ ] [cite_start]**FTPサーバー:** WordPressウェブサイトのボリュームを指すように設定 [cite: 200]。
- [ ] [cite_start]**静的ウェブサイト:** PHP以外の言語で作成（例: 自己紹介サイトなど） [cite: 201]。
- [ ] [cite_start]**Adminer:** データベース管理ツール [cite: 202]。
- [ ] [cite_start]**自由選択サービス:** 有用と思われる任意のサービス（評価時に理由を説明） [cite: 203]。

---

## 4. ドキュメント要件
[cite_start]ルートディレクトリに以下の3つのMarkdownファイルを配置すること [cite: 163, 181]。

1. [cite_start]**README.md** [cite: 164]
   - [cite_start]1行目に指定の斜体文言（`This project has been created...`） [cite: 165]。
   - [cite_start]プロジェクトの説明、実行方法 [cite: 166, 167]。
   - [cite_start]AIの使用箇所・方法 [cite: 168]。
   - [cite_start]技術的選択の比較（VM vs Docker、シークレット vs 環境変数、ネットワーク、ボリューム等） [cite: 171, 172, 174, 175, 176, 177]。
2. [cite_start]**USER_DOC.md** [cite: 182]
   - [cite_start]エンドユーザー向け。起動/停止、サイトへのアクセス方法、認証情報の管理方法など [cite: 184, 185, 186]。
3. [cite_start]**DEV_DOC.md** [cite: 188]
   - [cite_start]開発者向け。環境構築手順、Makefileを使ったビルド、データの永続化について [cite: 189, 190, 192]。

---

## 5. 1Day RTA スケジュール (1日完走プラン)

### ☀️ 午前：土台作りとDB（目標：2〜3時間）
- [ ] `srcs` フォルダ配下のディレクトリ構成を作成。
- [ ] `srcs/.env` を作成し、DB情報やドメイン名を定義。
- [ ] 最強の `Makefile`（up, down, clean, fclean）を作成。
- [ ] `docker-compose.yml` の骨組み（services, networks, volumes）を定義。
- [ ] MariaDBコンテナの構築（Alpineベース、`entrypoint.sh`でDB初期化、PID1で起動）。

### 🌤️ 昼〜午後：WordPressとNGINXの開通（目標：3〜4時間）
- [ ] WordPress + php-fpm コンテナの構築（`wp-cli`でダウンロード＆インストール自動化）。
- [ ] NGINXコンテナの構築（自己署名証明書の発行、TLSv1.2/1.3設定、9000番ポートへのルーティング）。
- [ ] `/etc/hosts` に `127.0.0.1 hattori.42.fr` を追加。
- [ ] ブラウザでアクセスし、WordPressの画面が出れば **必須パート完了！**

### 🌆 夕方：ボーナスパートのラッシュ（目標：3時間）
- [ ] Redisコンテナ追加＆WordPress連携。
- [ ] Adminerコンテナ追加＆ルーティング設定。
- [ ] 静的ウェブサイト（React/Go等）コンテナ追加。
- [ ] FTPサーバー（vsftpd等）コンテナ追加＆WordPressボリュームのマウント。

### 🌙 夜：ドキュメントと最終チェック（目標：1.5時間）
- [ ] `README.md`, `USER_DOC.md`, `DEV_DOC.md` の作成。
- [ ] `.env` 以外の場所にパスワードが漏れていないか最終確認。
- [ ] `make fclean` からの `make up` で全て正常に立ち上がるかテスト。