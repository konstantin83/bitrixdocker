ARG PHP_VERSION

FROM php:${PHP_VERSION}-fpm

# На каждый RUN создается новый слой в образе, поэтому рекомендуется объединять команды.
RUN apt-get update && apt-get install -y \
        curl \
        wget \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libonig-dev \
        libzip-dev \
        unzip \
        libmcrypt-dev \
        libldb-dev libldap2-dev \
        zsh \
        nano \
        && pecl install mcrypt excimer \
        && docker-php-ext-enable mcrypt \
        && docker-php-ext-install -j$(nproc) iconv mbstring mysqli pdo_mysql zip \
        && docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install opcache \
        && docker-php-ext-install ldap \
        && docker-php-ext-install calendar \
        && docker-php-ext-enable ldap

RUN chsh -s $(which zsh) \
        && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
        /usr/bin/zsh

RUN printf "\n" | pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

#RUN pecl install zip

# XDebug (только с версии PHP 8+)
# RUN yes | pecl install xdebug \
#     && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
#     && echo "[xdebug]\n \
#     xdebug.mode=develop,debug\n \
#     xdebug.client_host=host.docker.internal\n \
#     xdebug.client_port = 9003\n \
#     xdebug.start_with_request=yes\n \
#     xdebug.log=/var/www/html/xd.log\n" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD php.ini /usr/local/etc/php/conf.d/40-custom.ini

RUN usermod -u 1000 www-data

WORKDIR /var/www/html

CMD ["php-fpm"]
