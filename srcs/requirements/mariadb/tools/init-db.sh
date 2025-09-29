#!/bin/bash

if [ ! -d "/var/lib/mysql/mysql" ]; then

mysql_install_db --user=mysql --datadir=/var/lib/mysql
mysqld_safe --user=mysql --datadir=/var/lib/mysql & sleep 10

mysql -e "CREATE DATABASE $MYSQL_DATABASE;"
mysql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown

fi
exec mysqld_safe