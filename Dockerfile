# Start with a PHP 7.3 base image
FROM php:7.3

# Install some dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    mbstring \
    zip \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set the working directory to /var/www
WORKDIR /var/www

# Copy the application code to the container
COPY . /var/www

# Install the application dependencies
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && \
    composer dump-autoload --no-scripts --no-dev --optimize

# Set permissions for the storage and bootstrap cache directories
RUN chmod -R 777 storage bootstrap/cache

# Expose port 8000 and start PHP's built-in web server
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host", "0.0.0.0", "--port", "8000"]
