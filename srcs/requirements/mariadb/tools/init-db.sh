#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Check if MariaDB is already initialized by checking for our specific database
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
	echo "Initializing MariaDB..."
	
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	
	mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-grant-tables &
	
	until mysqladmin ping --silent 2>/dev/null; do
		sleep 1
	done
	
	echo "Creating database and user..."
	mysql -u root <<-EOSQL
		FLUSH PRIVILEGES;
		CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
		CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
		GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
		FLUSH PRIVILEGES;
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.user WHERE User='';
		FLUSH PRIVILEGES;
	EOSQL
	
	# Get the mysqld PID and kill it gracefully
	pkill -15 mysqld
	sleep 3
	
	echo "MariaDB initialization complete!"
fi

echo "Starting MariaDB..."
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0