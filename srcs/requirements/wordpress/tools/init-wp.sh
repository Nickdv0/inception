#!/bin/bash

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
	sleep 2
done
echo "MariaDB is ready!"

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    
    # Create wp-config
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$(cat /run/secrets/db_password.txt)" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root
    
    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password.txt)" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root
    
    # Create first additional user
    wp user create $WORDPRESS_USER $WORDPRESS_USER_EMAIL \
        --role=author \
        --user_pass="$(cat /tun/secrets/wp_user_password.txt)" \
        --allow-root
    
    # Create second additional user
    wp user create user2 user2@example.com \
        --role=editor \
        --user_pass="user2_password" \
        --allow-root
fi

chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

exec php-fpm7.4 -F
