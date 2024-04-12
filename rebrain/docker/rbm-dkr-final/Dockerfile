FROM php:7.2-fpm

# Prepare environment variabiles defaults
ENV TITLE=FingerSpeed
ENV MODE=frontend
ENV PASSWORD=password
ENV TELEMETRY=true
ENV ENABLE_ID_OBFUSCATION=false
ENV REDACT_IP_ADDRESSES=false

RUN apt-get update -y \
    && apt-get install -y nginx \
       libfreetype6-dev \
       libjpeg62-turbo-dev \
       libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

COPY nginx/default.conf /etc/nginx/sites-enabled/default

RUN chown www-data:www-data /var/www/html

# Prepare files and folders

RUN mkdir -p /speedtest/

# Copy sources

COPY backend/ /speedtest/backend

COPY results/* /speedtest/results/

COPY *.js /speedtest/

COPY docker/*.php /speedtest/
COPY docker/entrypoint.sh /

# Final touches

EXPOSE 80
CMD ["bash", "/entrypoint.sh"]

