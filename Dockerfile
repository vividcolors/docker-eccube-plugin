FROM php:7.2-apache-stretch

ARG NAME

ENV APP_DIR /app
ENV APPLICATION_ENV development
# ENV DATABASE_URL mysql://ecb:12345@mysql/ecb

RUN apt-get update && \
    apt-get install -y git-core zip nano && \
    apt-get install -y ssl-cert --no-install-recommends && \
    apt-get install -y libicu-dev && \
    apt-get install -y zlib1g-dev && \
    a2enmod ssl rewrite

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');    \
    \$sig = file_get_contents('https://composer.github.io/installer.sig');      \
    if (trim(\$sig) === hash_file('SHA384', 'composer-setup.php')) exit(0);     \
    echo 'ERROR: Invalid installer signature' . PHP_EOL;                        \
    unlink('composer-setup.php');                                               \
    exit(1);"                                                                   \
 && php composer-setup.php -- --filename=composer --install-dir=/usr/local/bin  \
 && rm composer-setup.php

 RUN docker-php-ext-install mysqli && \
     docker-php-ext-install zip && \
     docker-php-ext-install intl && \
     docker-php-ext-install pdo_mysql && \
     pecl install apcu && docker-php-ext-enable apcu && \
     docker-php-ext-configure opcache --enable-opcache && docker-php-ext-install opcache

ENV APACHE_DOCUMENT_ROOT /app

COPY conf/ssl-default.conf /etc/apache2/sites-enabled/
COPY conf/000-default.conf /etc/apache2/sites-enabled/

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80
EXPOSE 443

WORKDIR /app

RUN composer create-project ec-cube/ec-cube . --keep-vcs

VOLUME $APP_DIR/app/$NAME
