# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Структура из двух git-репозиториев

Этот корень — Docker-окружение (nginx/php-fpm/MariaDB/Redis), сам Bitrix-проект живёт в `www/` и имеет **собственный git**. Корневой `.gitignore` намеренно игнорирует `/www/`.

- Коммиты, ветки, PR для кода приложения — всегда из `www/` (`cd www && git …`).
- Коммиты в корень — только для изменений Docker-окружения, `Makefile`, `nginx/`, `php/`, `.env.default` и т. п.
- Композитный PHP-код приложения находится в `www/local/` (composer, PSR-4, тесты, миграции).

## Команды окружения (запускать из корня)

- `make init` — первичная установка: скачивает `bitrixsetup.php`, `bitrix_server_test.php`, `restore.php` в `www/` и копирует `.env.default` → `.env`.
- `make up` / `make stop` / `make down` / `make restart` — управление контейнерами (`docker compose`).
- `make build` / `make buildv` / `make buildf` — сборка образов (обычная / подробный вывод / без кеша).
- Окружение жёстко `local`: переменная `BITRIX_ENV=local` задаётся в nginx и влияет на логику `bitrix/.settings_extra.php`.
- Временные файлы Bitrix (`BX_TEMPORARY_FILES_DIRECTORY`) вынесены в `/dev/shm` контейнера php (лимит 1 ГБ). MariaDB тоже использует `tmpfs` для temp.

## Composer / PHP-приложение (`www/local/`)

- Автозагрузка PSR-4: `Mir\Krepcom\` → `src/`, `Mir\Krepcom\Tests\` → `tests/`.
- Установка зависимостей: `cd www/local && composer install`. Важные зависимости: `slim/slim` (API-роутер), `slim/psr7`, `sentry/sentry`.
- Ключевой `init.php` (`www/local/php_interface/init.php`) подключает composer autoload и длинный список `include/classes/*` и `include/events/*` — при добавлении новых классов/обработчиков регистрировать их там.

## Тесты

- PHPUnit 12, конфиг: `www/local/phpunit.xml`, bootstrap: `www/local/tests/bootstrap.php`.
- Bootstrap подгружает **стабы Bitrix-классов** (`tests/_stubs/BitrixStubs.php`) и **моки репозиториев** (`tests/_stubs/RepositoryMocks.php`) **ДО** composer autoloader. Это позволяет unit-тестам сервисов не зависеть от реального Bitrix-ядра — PHP видит классы уже определёнными и не грузит настоящие файлы. Соответственно: при добавлении нового репозитория/Bitrix-класса, который используется в тестируемом сервисе, нужно добавить стаб/мок в `_stubs/`.
- Запуск всех тестов: `cd www/local && vendor/bin/phpunit`.
- Один тест / фильтр: `vendor/bin/phpunit --filter ProductServiceTest` или `vendor/bin/phpunit tests/Api/Service/ProductServiceTest.php`.

## Архитектура REST API

Точка входа — `www/api/index.php`: Slim 4, `setBasePath('/api')`, `addBodyParsingMiddleware()`, все ошибки логируются в Sentry с тегом `module=api`.

Слои (`www/local/src/Api/`):

- `AuthService.php` — проверка токена в заголовке `Authorization` (вызывается в каждом хендлере перед бизнес-логикой).
- `Catalog/Service/ProductService.php` — оркестрация: валидация, маршрутизация вызовов к репозиториям, накопление ошибок в `Bitrix\Main\Result` и выброс общим `ArgumentException` с `http_response_code(400|404)` в конце (важно: код ответа пробрасывается через глобальный `http_response_code()`, а сам `$response` отдаёт его в `withStatus(http_response_code() ?: 500)` в `index.php`).
- `Catalog/Repository/*Repository.php` — тонкие обёртки над Bitrix-сущностями (`ProductRepository`, `StoreRepository`, `PriceRepository`, `PropertyRepository`). **Все методы статические** — так же реализованы моки в тестах.
- `Catalog/Service/PropertyService.php`, `ValidateService.php` — вспомогательные доменные сервисы.

При добавлении новой сущности следовать этому разделению: хендлер в `www/api/index.php` → `Service` в `src/Api/<Domain>/Service/` → `Repository` в `src/Api/<Domain>/Repository/` → стаб/мок в `tests/_stubs/RepositoryMocks.php` → тест в `tests/Api/Service/`.

## Миграции

`sprint.migration`. Файлы — `www/local/php_interface/migrations/`. На деплое (GitLab CI) применяются автоматически: `php bitrix/modules/sprint.migration/tools/migrate.php up`.

## Деплой (`www/.gitlab-ci.yml`)

- Ветка `dev` → SSH-деплой на dev-сервер (пользователь `dev`).
- Ветка `master` → SSH-деплой на prod-сервер (пользователь `bitrix`).
- Шаги обоих пайплайнов: `git pull` → `composer install` → `npm install && npm run build` (если есть `package.json`) → `migrate.php up`.
- Merge request события не триггерят деплой (`when: never`).

## Конвенции коммитов и веток

- Сообщения коммитов — **на русском, в прошедшем времени** («добавлен», «исправлен», «обновлён»).
- Тикеты из Jira: префикс `PRI-XXX:` в начале сообщения (пример: `PRI-325: API для массового создания товаров + юнит-тесты`).
- Основная ветка приложения — `master` (prod), промежуточная — `dev`. В корневом репо git — `main`.

## Нестандартные моменты, о которых легко забыть

- `www/local/src/Api/Catalog/Service/ProductService.php` использует `http_response_code()` как глобальный side-effect для передачи HTTP-статуса наружу — не менять на throw+map без ревизии `www/api/index.php`.
- В `www/.gitignore` запрещены `*.xml` с исключением `!/local/phpunit.xml` — при добавлении XML-конфигов проверять, что они не попадут под игнор.
- Папки `www/bitrix/` и `www/upload/` игнорируются — не пытаться их коммитить.
- Nginx слушает только `127.0.0.1` (порт 80/443) и MariaDB только `127.0.0.1:3306` — снаружи хоста контейнеры недоступны.

## Сессии: `mode: separated` для устранения lock-конкуренции на корзине

В `www/bitrix/.settings_extra.php` (case 'local') сессии настроены в режиме `separated`:

```php
$setting['session'] = [
    'value' => [
        'mode'     => 'separated',
        'handlers' => [
            'general' => ['type' => 'redis', 'host' => 'redis', 'port' => '6379'],
            'kernel'  => 'encrypted_cookies',
        ],
    ],
];
```

**Зачем.** На странице `/personal/basket.php` параллельно запускаются ~6-8 ajax (`sale.basket.basket/ajax`, `sale.basket.basket.line/ajax`, `desktop-basket.php`, `sticky-basket.php`, `mobile-basket.php`, etc). У всех один `PHPSESSID`, поэтому каждый процесс ждёт session-lock от предыдущего. На macOS-докере с медленным bind-mount snowball-задержка вырастала до 30-50 секунд (95-99% времени запроса — ожидание `session_start()`, не Bitrix-логика).

**Как это снимает.** В `separated` kernel-данные (`$_SESSION['BX']`: язык, security tokens) уходят в зашифрованную cookie без блокировок, а пользовательские данные сессии остаются в Redis под собственным lock-ом. Параллельные ajax, которым не нужно писать в общую часть, перестают сериализоваться.

**Жёсткое требование Bitrix.** При `mode: separated` `handlers['kernel']` должен быть **строкой `'encrypted_cookies'`** (не массивом, не `redis`), иначе `Bitrix\Main\NotSupportedException: "Kernel session works only with encrypted_cookies"`.

**После смены настройки** — `redis-cli FLUSHALL` обязателен (старые сессии в новой схеме не валидны), пользователей разлогинит.

**Файл `bitrix/.settings_extra.php` в .gitignore**, поэтому правка не попадает в репозиторий — её нужно прописать вручную в `case 'dev':`/`case 'master':` на нужных серверах через SSH, если хочется применить решение там.

**Эффект на проде.** Меньше, чем локально (на быстром I/O lock держится десятки мс, а не секунды), но на корзине/чекауте измеримый. Альтернатива/дополнение, дающее больший эффект: `session_write_close()` в начале read-only ajax (мини-корзина, sticky-basket).
