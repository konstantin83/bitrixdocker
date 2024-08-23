ifneq ($(wildcard .env),)
  $(info [+] Файл .env существует)
  include .env
endif

.DEFAULT_GOAL := help
.PHONY: help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
        | sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1###\3/p' \
        | column -t  -s '###'

install: ## Установка
	@if ! test -f .env; \
		then \
			echo [!] Файл .env не существует, копируем из .env.default; \
			cp .env.default .env; \
			bash -c 'read -p "Укажите домен: " SITE_NAME && echo $$SITE_NAME && sed -i "s/\(SITE_NAME=\).*/\1$$SITE_NAME/g" .env'; \
			bash -c 'read -p "Укажите порт: " SITE_PORT && echo $$SITE_PORT && sed -i "s/\(SITE_PORT=\).*/\1$$SITE_PORT/g" .env'; \
	fi

bitrix: ## Скачать установочные файлы битрикс
	@wget http://dev.1c-bitrix.ru/download/scripts/bitrix_server_test.php -O ./www/bitrix_server_test.php
	@wget http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php -O ./www/bitrixsetup.php
	@echo "<?php\nphpinfo();" > ./www/index.php

up: ## Завести контейнер
	@if ! test -f .env; \
		then \
			echo [!] Файл .env не существует, запустите make install; \
			false; \
	fi
	@docker compose -p krepcom up -d
	@echo http://$(SITE_NAME)/

stop: ## Остановить контейнер
	@docker compose stop

down:  ## Потушить контейнер
	@docker compose down

build: ## Собрать контейнер (без вывода)
	@docker compose build

buildv: ## Собрать контейнер (с подробным выводом)
	@docker compose build --progress plain

buildf: ## Собрать контейнер (с подробным выводом и без кеша)
	@docker compose build --progress plain --no-cache
