FROM php:8.1-fpm
LABEL maintainer="Amri Karisma <amrikarisma@live.com>"

# Set working directory
WORKDIR /var/www

# Add docker php ext repo
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install php extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
	install-php-extensions mbstring pdo_mysql mysqli zip exif pcntl gd memcached bcmath


# Install dependencies
RUN apt-get update && apt-get install -y \
	build-essential \
	libpng-dev \
	libjpeg62-turbo-dev \
	libfreetype6-dev \
	locales \
	nano \
	zip \
	jpegoptim optipng pngquant gifsicle \
	unzip \
	git \
	curl \
	lua-zlib-dev \
	libmemcached-dev \
	nginx \
	mariadb-client \
	supervisor \
	ca-certificates \
	gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update && apt-get install -y nodejs

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN addgroup --gid 1000 www \
	&& adduser \
	--disabled-password \
	--gecos "" \
	--home "$(pwd)" \
	--ingroup www \
	--no-create-home \
	--uid 1000 \
	www

# PHP Error Log Files
RUN mkdir /var/log/php
RUN touch /var/log/php/errors.log && chmod 777 /var/log/php/errors.log

# Copy PHP and Nginx config
COPY --chown=root:root supervisor.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=root:root php.ini /usr/local/etc/php/conf.d/app.ini
COPY --chown=root:root nginx.conf /etc/nginx/sites-enabled/default

# Install Node.js
RUN npm install npm@latest -g

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*