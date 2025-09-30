FROM debian:11
RUN apt-get update && apt-get install -y mariadb-server mariadb-client
COPY ./conf/default_db.cnf /etc/mariadb/conf.d/
EXPOSE 3306

COPY ./tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh
CMD ["/usr/local/bin/init-db.sh"]