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

WORKDIR /tmp
RUN wget https://wordpress.org/latest.tar.gz && \
	tar -xvzf latest.tar.gz && \
	mkdir -p /var/www/html && \
	cp -r wordpress/* /var/www/html/ && \
	rm -rf latest.tar.gz wordpress
RUN mkdir -p /run/php

RUN wget -O wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp


EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/init-wp.sh /usr/local/bin/init-wp.sh
RUN chmod +x /usr/local/bin/init-wp.sh
RUN chown -R www-data:www-data /var/www/html
CMD ["/usr/local/bin/init-wp.sh"]
