# docker-eccube-plugin

EC-CUBE4のプラグイン開発のためのDocker環境を構築します。

## Dockerfileの使い方

Dockerイメージを作る際には、プラグインの名前をNAME引数で与えてください。  
同時に、同じ名前のディレクトリをプロジェクトディレクトリに作っておいてください。このディレクトリがEC-CUBEコンテナのapp/Plugin配下にマウントされます。

```
$ docker build -t myawesome-web --build-arg NAME="MyAwesomePlugin" .
```

EC-CUBEのDockerイメージはapacheとphpのみを含みます。MTAやDBは入っていません。  
イメージを作った後には、EC-CUBEのeccube:installコマンドを実行して、MTAやDBを含むEC-CUBE環境をセットアップする必要があります。  

```
### コンテナ内で実行
$ bin/console eccube:install

### ec-cube4.0.0では、"The process "bin/console doctrine:schema:create" 
### exceeded the timeout of 60 seconds."というエラーが出て処理が正常終了
### しない場合があります。これは、処理がタイムアウトしているだけですので致命的
### ではありません。コマンドを何度か立て続けに実行していると正常終了したりします。
### それでもダメな場合は、vendor/symfony/process/Process.phpのコンストラクタ
### で$timeout = 60となっているのを一時的に変えてください。
```

便利のため、MTAやDBを含むEC-CUBE環境全体を構築するdocker-compose.ymlのサンプルを含めておきました。下記です。

## docker-compose.ymlの使い方

MailHog（ダミーのMTA）、MySQLを含むEC-CUBE全体の環境を構築します。  
docker-compose.ymlにリネームしてから適当に中身を編集して使ってください。  
下記の一連のコマンドで進めていけば環境を構築できるはずです。

```
$ mkdir MyAwesomePlugin
$ docker build -t myawesome-web --build-arg NAME="MyAwesomePlugin" .
$ docker-compose up -d
$ docker exec -it myawesome-web bash
> bin/console eccube:install
### DB: mysql://ecb:12345@mysql/ecb
### MTA: smtp://mailhog:1025

### http://localhost/ でEC-CUBEが起動。
### http://localhost:8025/ でメールを確認。
### プロジェクトディレクトリのmysql-data配下に、MySQLのデータが記録されます。
```
