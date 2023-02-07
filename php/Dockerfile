FROM php:7.4-fpm

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
	libmcrypt-dev \
        && pecl install mcrypt-1.0.3 \
	&& docker-php-ext-enable mcrypt \
        && docker-php-ext-install -j$(nproc) iconv mbstring mysqli pdo_mysql zip \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install opcache

RUN printf "\n" | pecl install -o -f redis
RUN rm -rf /tmp/pear
RUN docker-php-ext-enable redis

RUN pecl install zip

# RUN yes | pecl install xdebug \
#     && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
#     && echo "\
#     zend_extension=xdebug \
#     [xdebug]\
#     xdebug.mode=develop,debug\
#     xdebug.client_host=host.docker.internal\
#     xdebug.client_port = 9003\
#     xdebug.start_with_request=yes\
#     xdebug.log=/var/www/html/xd.log" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ADD php.ini /usr/local/etc/php/conf.d/40-custom.ini

RUN usermod -u 1000 www-data

WORKDIR /var/www

CMD ["php-fpm"]