FROM php:7.2-fpm

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta
ENV APP_HOME=/var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    g++ \
    pkg-config \
    libz-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxml2-dev \
    zlib1g-dev libicu-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    libxslt1-dev \
    libmcrypt-dev \
    unixodbc-dev \
    locales \
    zip \
    unzip \
    curl \
    git \
    vim \
    libpq-dev \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl channel-update pecl.php.net

RUN echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo date.timezone = $TZ > /usr/local/etc/php/conf.d/docker-php-ext-timezone.ini

WORKDIR ${APP_HOME}

ADD . ${APP_HOME}

RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    && pecl install mcrypt-1.0.1 \
    && docker-php-ext-install mbstring \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql \
    && docker-php-ext-install zip \
    && docker-php-ext-install json \
    && docker-php-ext-install soap \
    && docker-php-ext-install xml \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install xsl

RUN docker-php-ext-enable intl \
    && docker-php-ext-enable pdo \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable mbstring \
    && docker-php-ext-enable pdo_pgsql \
    && docker-php-ext-enable pgsql \
    && docker-php-ext-enable zip \
    && docker-php-ext-enable soap \
    && docker-php-ext-enable json \
    && docker-php-ext-enable xml \
    && docker-php-ext-enable xsl \
    && docker-php-ext-enable bcmath

RUN curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

EXPOSE 9000
CMD ["php-fpm"]