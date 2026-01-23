# Developer Documentation

## Setup

### Prerequisites
```bash
# Install required tools
docker --version
docker compose version
make --version
```

### Quick Start
```bash
# 1. Configure domain (optional)
echo "127.0.0.1   nde-vant.42.fr" | sudo tee -a /etc/hosts

# 2. Secrets are already configured in secrets/
ls -la secrets/  # db_password.txt, wp_admin_password.txt, etc.

# 3. Build and run
make
```

**Note:** Project uses port 8443 (not 443) for rootless Docker compatibility.

---

## Architecture

**3 Containers:**
- NGINX (443 internal, 443 external) → WordPress (9000) → MariaDB (3306)
- Network: inception (bridge)
- Volumes: ~/data/mysql, ~/data/wordpress

**Data Flow:**
```
User → NGINX (HTTPS:443) → WordPress (FastCGI:9000) → MariaDB (MySQL:3306)
```

**Secrets Management:**
- Mounted in `/run/secrets/`
- Not visible in `docker inspect`
- Loaded at runtime by init scripts

---

## Commands

### Basic
```bash
make              # Build and start
make down         # Stop
make clean        # Stop + remove volumes
make fclean       # Complete cleanup + images
make re           # Rebuild from scratch
```

### Docker Compose
```bash
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml build --no-cache
```

### Inspect Containers
```bash
docker ps                           # List running
docker logs nginx                   # View logs
docker logs -f wordpress            # Follow logs
docker exec -it mariadb bash        # Shell access
docker exec -it wordpress bash      # WordPress shell
```

---

## Testing

### Check Status
```bash
docker ps                                  # All should be "Up"
curl -k https://localhost:443             # Test website
curl -k https://localhost:443/wp-admin/   # Test admin
```

### Verify Requirements
```bash
# Auto-restart
docker inspect nginx --format='{{.HostConfig.RestartPolicy.Name}}'
# Should return: always

# TLS version
docker exec nginx nginx -V 2>&1 | grep -i tls
# Should show TLSv1.2 and TLSv1.3

# Network
docker network inspect srcs_inception

# Volumes
docker volume ls | grep -E "mariadb|wordpress"

# Secrets
docker exec wordpress ls -la /run/secrets/
```

### Test Database
```bash
# From WordPress container
docker exec wordpress mysqladmin ping -h mariadb -u wpuser -p"$(cat secrets/db_password.txt)"

# Connect to MySQL
docker exec -it mariadb mysql -u root -p"$(cat secrets/db_root_password.txt)"

# Show databases
docker exec mariadb mysql -u wpuser -p"$(cat secrets/db_password.txt)" -e "SHOW DATABASES;"

# Show WordPress users
docker exec mariadb mysql -u wpuser -p"$(cat secrets/db_password.txt)" -e "SELECT user_login, user_email FROM wordpress.wp_users;"
```

### Test WordPress
```bash
# List users
docker exec wordpress wp user list --path=/var/www/html --allow-root

# Check installation
docker exec wordpress wp core is-installed --path=/var/www/html --allow-root

# Get site URL
docker exec wordpress wp option get siteurl --path=/var/www/html --allow-root
```

### Test NGINX
```bash
docker exec nginx nginx -t          # Test config
docker exec nginx ls /var/www/html  # Check WordPress files
docker exec nginx cat /etc/nginx/nginx.conf  # View config
```

---

## Debugging

### View Logs
```bash
# All logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs in real-time
docker logs -f wordpress

# Last 50 lines
docker logs --tail 50 mariadb
```

### Check Initialization
```bash
# WordPress initialization status
docker exec wordpress ls -la /var/www/html/wp-config.php

# MariaDB database check
docker exec mariadb ls -la /var/lib/mysql/wordpress/

# Check if setup completed
docker logs wordpress 2>&1 | grep "WordPress setup complete"
```

### Network Connectivity
```bash
# Check if containers can reach each other
docker exec wordpress ping -c 3 mariadb
docker exec wordpress nc -zv mariadb 3306  # Requires netcat

# Test database connection from WordPress
docker exec wordpress mysqladmin ping -h mariadb -u wpuser -p"$(cat secrets/db_password.txt)"
```

### Container Access
```bash
# Access container shell
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx bash

# Run commands without entering shell
docker exec wordpress ls -la /var/www/html
docker exec mariadb mysql -u root -p"$(cat secrets/db_root_password.txt)" -e "SHOW DATABASES;"
```

### Reset and Rebuild
```bash
# Clean everything
make fclean

# Rebuild specific service
docker compose -f srcs/docker-compose.yml up -d --build wordpress

# View build logs
docker compose -f srcs/docker-compose.yml build --no-cache --progress=plain
```

---

## File Locations

**Host:**
- ~/data/mysql → MariaDB data
- ~/data/wordpress → WordPress files
- secrets/ → Password files

**Container paths:**
- NGINX: `/var/www/html`, `/etc/nginx/nginx.conf`, `/etc/ssl/certs/`
- WordPress: `/var/www/html`, `/run/secrets/`, `/tmp/wordpress` (source)
- MariaDB: `/var/lib/mysql`, `/run/secrets/`

**Init Scripts:**
- WordPress: `/usr/local/bin/init-wp.sh`
- MariaDB: `/usr/local/bin/init-db.sh`

---

## Key Features

### WordPress Auto-Setup
- Copies WordPress files from `/tmp/wordpress` to volume
- Creates `wp-config.php` with retry logic
- Installs WordPress core
- Creates admin user (`nde-vant`)
- Creates additional user (`regular_user`)

### MariaDB Auto-Initialization
- Runs `mysql_install_db` on first start
- Uses `--skip-grant-tables` for initial setup
- Creates `wordpress` database
- Creates `wpuser` with proper permissions
- Sets secure root password
- Removes test database and anonymous users

### Error Handling
- Retry logic for database connections (30 attempts)
- Retry logic for wp-config creation (5 attempts)
- Proper exit codes on failure
- Detailed logging for debugging
