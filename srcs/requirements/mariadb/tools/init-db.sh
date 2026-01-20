#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Check if our custom database exists instead of just the mysql system DB
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then

mysql_install_db --user=mysql --datadir=/var/lib/mysql
mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 &
until mysqladmin ping --silent 2>/dev/null; do
	sleep 1
done

mysql -e "CREATE DATABASE $MYSQL_DATABASE;"
mysql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"
# Better security - remove test database and anonymous users
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysqladmin shutdown -u root -p$MYSQL_ROOT_PASSWORD

fi

exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0