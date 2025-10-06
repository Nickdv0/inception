#!/bin/bash

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
	sleep 2
done
echo "MariaDB is ready!"

if [ ! -f "/var/www/html/wp-config.php" ]; then
cat > /var/www/html/wp-config.php <<EOF
<?php
define('DB_NAME', '$MYSQL_DATABASE');
define('DB_USER', '$MYSQL_USER');
define('DB_PASSWORD', '$MYSQL_PASSWORD');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF
fi

chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

exec php-fpm7.4 -F