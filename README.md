# Docker-compose для Битрикс

Необходимо установить [Docker](https://docs.docker.com/engine/install/debian/) и [Docker-compose](https://docs.docker.com/compose/install/)

#### Переименовать **hosts/clean.conf** и/или исправить в нём **server_name** ####

#### Запуск контейнера: ####
```
docker-compose build
docker-compose up -d
```
#### После каждого изменения clean.conf: ####
`docker-compose up -d --no-deps --force-recreate`

#### После изменения php/Dockerfile: ####
`docker-compose build`

#### Остановить контейнер: ####
`docker-compose stop`

#### Скрипты проверки и установки Битрикс: ####
В папкe www выполнить подходящее:
```
wget https://dev.1c-bitrix.ru/download/scripts/bitrix_server_test.php
wget http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php
wget https://www.1c-bitrix.ru/download/files/scripts/restore.php
```

