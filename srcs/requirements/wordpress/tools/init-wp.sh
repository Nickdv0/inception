#!/bin/bash

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

echo "Waiting for MariaDB to be ready..."
# Wait for MariaDB to accept connections AND have the database ready
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    # Check if we can actually connect AND query the database
    if mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; then
        echo "MariaDB is ready and database is accessible!"
        break
    fi
    attempt=$((attempt + 1))
    echo "Waiting for MariaDB... (attempt $attempt/$max_attempts)"
    sleep 3
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: Could not connect to MariaDB database after $max_attempts attempts"
    exit 1
fi

# Copy WordPress files to volume if they don't exist
if [ ! -f /var/www/html/index.php ]; then
    echo "Copying WordPress files to volume..."
    cp -rp /tmp/wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html
fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Setting up WordPress..."
    
    # Create wp-config with retry logic
    max_retries=5
    retry=0
    while [ $retry -lt $max_retries ]; do
        # Test database connection first
        if ! mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" >/dev/null 2>&1; then
            echo "Database connection test failed, retrying... ($((retry + 1))/$max_retries)"
            retry=$((retry + 1))
            sleep 3
            continue
        fi
        
        if wp config create \
            --dbname="$WORDPRESS_DB_NAME" \
            --dbuser="$WORDPRESS_DB_USER" \
            --dbpass="$WORDPRESS_DB_PASSWORD" \
            --dbhost="$WORDPRESS_DB_HOST" \
            --allow-root 2>/dev/null; then
            echo "wp-config.php created successfully!"
            break
        fi
        retry=$((retry + 1))
        echo "Failed to create wp-config.php, retrying... ($retry/$max_retries)"
        sleep 3
    done
    
    if [ $retry -eq $max_retries ]; then
        echo "ERROR: Could not create wp-config.php after $max_retries attempts"
        exit 1
    fi
    
    echo "Installing WordPress core..."
    # Install WordPress
    if wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root; then
        echo "WordPress installed successfully!"
    else
        echo "ERROR: WordPress installation failed"
        exit 1
    fi
    
    echo "Creating additional user..."
    # Create additional user
    if wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
        --role=author \
        --user_pass="$(cat /run/secrets/wp_user_password)" \
        --allow-root; then
        echo "Additional user created successfully!"
    else
        echo "ERROR: Failed to create additional user"
        exit 1
    fi
    
    echo "WordPress setup complete!"
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
