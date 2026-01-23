FROM debian:11
RUN apt-get update && apt-get install -y \
	wget \
	php7.4 \
	php7.4-curl \
	php7.4-fpm \
	php7.4-gd \
	php7.4-intl \
	php7.4-mbstring \
	php7.4-mysql \
	php7.4-xml \
	php7.4-zip \
	mariadb-client && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

# Download WordPress to /tmp (not /var/www/html - volume will overwrite it!)
WORKDIR /tmp
RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xzf latest.tar.gz && \
	rm latest.tar.gz

# Install WP-CLI
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x /usr/local/bin/wp


EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/init-wp.sh /usr/local/bin/init-wp.sh
RUN chmod +x /usr/local/bin/init-wp.sh

CMD ["/usr/local/bin/init-wp.sh"]
