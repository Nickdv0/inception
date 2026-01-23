#!/bin/bash

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password.txt)

echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
	sleep 2
done
echo "MariaDB is ready!"

# Copy WordPress files to volume if they don't exist
if [ ! -f /var/www/html/index.php ]; then
    echo "Copying WordPress files to volume..."
    cp -rp /tmp/wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html
fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."
    
    # Create wp-config
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root
    
    echo "Installing WordPress core..."
    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password.txt)" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root
    
    echo "Creating additional user..."
    # Create additional user
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --role=author \
        --user_pass="$(cat /run/secrets/wp_user_password.txt)" \
        --allow-root
    
    echo "WordPress setup complete!"
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
