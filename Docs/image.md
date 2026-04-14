docker imageに書かれた設計をもとにDockerはDocker runができる

Docker imageは "docker file"に記述されたものに対して、
```sh
docker build -t <tag name> <file path>
```
-t はタグ名を設定できるオプション

というコマンドを打つことによってビルドできる。

そのDocker imageをRunするには

```sh
docker run -d --name <docker name> <docker image name>
```
-dはバックグラウンドで作成できるオプション

で実行可能。

実行したDockerに入るためのコマンドは

```sh
docker exec -it <docker name> sh
```
にて、sh内に入ることができる。

execを使えばdocker内に入らず、外部からコマンドを実行できる。
