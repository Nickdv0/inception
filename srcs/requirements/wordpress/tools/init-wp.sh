#!/bin/bash

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
	sleep 2
done
echo "MariaDB is ready!"

if [ ! -f "/var/www/html/wp-config.php" ]; then
cat > /var/www/html/wp-config.php <<EOF
<?php
define('DB_NAME', '$WORDPRESS_DB_NAME');
define('DB_USER', '$WORDPRESS_DB_USER');
define('DB_PASSWORD', '$WORDPRESS_DB_PASSWORD');
define('DB_HOST', '$WORDPRESS_DB_HOST');
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
