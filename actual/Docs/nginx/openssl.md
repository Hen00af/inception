まず、
```sh
    openssl req -x509 -nodes -days 365 \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=shattori.42.fr" \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt
```
以上のコマンドについて解説する。

x509 ・・・公開鍵基盤（PKI）においてデジタル証明書（電子証明書）のデータ形式を定めた国際的な標準規格

openssl req -x509・・・その標準規格を用いた暗号化を行なってもらう
-nodes -days 365・・・暗号の使用期限の設定

-subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/CN=shattori.42.fr" ・・・この証明書に書かれる、サーバは誰のものかを表す情報をもつもの。

-newkey rsa:2048　・・・ 暗号方式の指定

-keyout /etc/nginx/ssl/server.key ・・・　秘密鍵の生成場所

-out /etc/nginx/ssl/server.crt・・・暗号の生成場所

よって、このコマンドを日本語訳すると、

opensslコマンドで、指定したファイル内にx509の規格、rsa2048で暗号化した鍵と値を入れて欲しい。

というコマンドです。
これをnginxの
/etc/nginx/ssl/server.crt
/etc/nginx/ssl/server.key
に入れてあげて、

'''sh
    listen 443 ssl;

    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
'''

このように指定してあげれば、443ポートに来た通信はsslを使用して暗号化解除すると待ち構えるようになる。