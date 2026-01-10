FROM debian:11
RUN apt-get update && apt-get install -y wget php php-fpm php-mysql mariadb-client
RUN mkdir -p /var/www/html && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz && \
    cp -r wordpress/* /var/www/html/
RUN mkdir -p /run/php
EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./tools/init-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-wp.sh
RUN chown -R www-data:www-data /var/www/html
CMD ["/usr/local/bin/init-wp.sh"]