# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_VERSION=8.1
ARG NGINX_VERSION=stable
ARG COMPOSER_VERSION=lts
ARG NODE_VERSION=lts
ARG SYMFONY_CLI_VERSION=latest

FROM composer:${COMPOSER_VERSION} as composer

FROM node:${NODE_VERSION}-alpine as node

FROM ghcr.io/symfony-cli/symfony-cli:${SYMFONY_CLI_VERSION} as symfony_cli

FROM php:${PHP_VERSION}-fpm-alpine AS app_php

# persistent / runtime deps
RUN apk add --no-cache \
	acl \
	fcgi \
	file \
	gettext \
	git \
	gnu-libiconv \
	tzdata \
	;

# install gnu-libiconv and set LD_PRELOAD env to make iconv work fully on Alpine image.
# see https://github.com/docker-library/php/issues/240#issuecomment-763112749
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

ARG APCU_VERSION

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		intl \
		pdo_mysql \
		zip \
	; \
	pecl install \
		apcu${APCU_VERSION:+-${APCU_VERSION}} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

RUN ln -s $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

COPY docker/php/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

VOLUME /var/run/php

### Composer ###
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PATH="${PATH}:/root/.composer/vendor/bin"

### Node.js, npm and Yarn ###
# YARN_VERSION - latest stable release: use 'stable', classic version: set version number. Ex: 1.22.19
ARG YARN_VERSION=stable

COPY --from=node /usr/local/ /usr/local/
# this ensures we fix simlinks for npx, Yarn, and PnPm
RUN corepack disable && corepack enable
RUN corepack prepare yarn@${YARN_VERSION} --activate

### Symfony CLI ###
COPY --from=symfony_cli /usr/local/bin/symfony /usr/local/bin/symfony

### XDebug ###
ARG XDEBUG_VERSION=3.1.6

RUN set -eux; \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
	pecl install xdebug${XDEBUG_VERSION:+-${XDEBUG_VERSION}}; \
	docker-php-ext-enable xdebug; \
	apk del .build-deps

WORKDIR /app


FROM nginx:${NGINX_VERSION}-alpine AS app_nginx

RUN apk add --no-cache \
	openssl \
	tzdata \
	;

# Create self-signed SSL certificate
RUN mkdir -p /etc/ssl/private
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048  \
	-subj "/C=BR/ST=SP/O=Company, Inc./CN=$HOSTNAME" \
	-addext "subjectAltName=DNS:$HOSTNAME" \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt;

WORKDIR /app
