FROM debian:11
RUN apt-get update && apt-get install -y \
	mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld /run/mysqld

COPY ./conf/default_db.cnf /etc/mysql/mariadb/conf.d/50-server.cnf
# MariaDB port, added for clarity
EXPOSE 3306 

LABEL  maintainer="nde-vant"
LABEL  description="MariaDB database server for WordPress"


COPY ./tools/init-db.sh /usr/local/bin/init-db.sh
RUN chmod +x /usr/local/bin/init-db.sh
CMD ["/usr/local/bin/init-db.sh"]