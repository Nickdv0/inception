FROM debian:11
RUN apt-get update && apt-get install -y wget php php-fpm php-mysql
RUN wget https://wordpress.org/latest.tar.gz && tar -xvzf latest.tar.gz && mv wordpress /var/www/html
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/
EXPOSE 9000

COPY ./tools/init-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-wp.sh
CMD ["/usr/local/bin/init-wp.sh"]
VOLUME /var/www/html
RUN chown -R www-data:www-data /var/www/html