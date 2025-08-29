ifneq ($(wildcard .env),)
#  $(info [+] Файл .env существует)
  include .env
endif

.DEFAULT_GOAL := help
.PHONY: help

help: ## Показать доступные команды
	@awk -F':.*?## ' '/^[a-zA-Z0-9_-]+:.*##/ {printf "%-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: setup ## Установка
	@if ! test -f .env; \
		then \
			echo [!] Файл .env не существует, копируем из .env.default; \
			cp .env.default .env; \
	fi


setup: ## Скачать установочные файлы битрикс
	@mkdir -p ./www/upload/
	@wget http://dev.1c-bitrix.ru/download/scripts/bitrix_server_test.php -O ./www/bitrix_server_test.php
	@wget http://www.1c-bitrix.ru/download/scripts/bitrixsetup.php -O ./www/bitrixsetup.php
	@wget https://www.1c-bitrix.ru/download/files/scripts/restore.php -O ./www/restore.php

	@if ! test -f ./www/index.php; \
		then \
			echo [!] Файл index.php не существует, создаем; \
			echo "<?php\nphpinfo();" > ./www/index.php; \
	fi

up: ## Завести контейнер
	@docker compose up -d --wait

stop: ## Остановить контейнер (пауза)
	@docker compose stop

down:  ## Остановить контейнер
	@docker compose down

restart: ## Перезапустить контейнер
	@docker compose down && \
	docker compose up -d --wait;

build: ## Собрать контейнер (без вывода)
	@docker compose build

buildv: ## Собрать контейнер (с подробным выводом)
	@docker compose build --progress plain

buildf: ## Пересобрать контейнер с нуля без кеша (с подробным выводом)
	@docker compose build --progress plain --no-cache
