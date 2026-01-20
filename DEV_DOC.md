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
# 1. Configure domain
sudo sh -c 'echo "127.0.0.1 nde-vant.42.fr" >> /etc/hosts'

# 2. Fill secrets
# Edit: secrets/db_password.txt
# Edit: secrets/db_root_password.txt
# Edit: secrets/.env

# 3. Build and run
make
```

---

## Architecture

**3 Containers:**
- NGINX (443) → WordPress (9000) → MariaDB (3306)
- Network: inception (bridge)
- Volumes: ~/data/mysql, ~/data/wordpress

**Data Flow:**
```
User → NGINX (HTTPS) → WordPress (FastCGI) → MariaDB (MySQL)
```

---

## Commands

### Basic
```bash
make              # Build and start
make down         # Stop
make clean        # Stop + remove volumes
make fclean       # Complete cleanup
make re           # Rebuild from scratch
```

### Docker Compose
```bash
docker compose -f srcs/docker-compose.yml up -d
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml ps
```

### Inspect Containers
```bash
docker ps                           # List running
docker logs nginx                   # View logs
docker logs -f wordpress            # Follow logs
docker exec -it mariadb bash        # Shell access
```

---

## Testing

### Check Status
```bash
docker ps                           # All should be "Up"
curl -k https://nde-vant.42.fr      # Test website
```

### Verify Requirements
```bash
# Auto-restart
docker inspect nginx --format='{{.HostConfig.RestartPolicy.Name}}'

# TLS version
docker exec nginx nginx -V 2>&1 | grep -i tls

# Network
docker network inspect inception

# Volumes
docker volume ls | grep -E "mariadb|wordpress"
```

### Test Database
```bash
# From WordPress container
docker exec wordpress mysqladmin ping -h mariadb -u wpuser -p

# Connect to MySQL
docker exec -it mariadb mysql -u root -p
# Show databases, check wordpress exists
```

### Test NGINX
```bash
docker exec nginx nginx -t          # Test config
docker exec nginx ls /var/www/html  # Check WordPress files
```

---

## Debugging

```bash
# View logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Check if containers are running
docker ps -a

# Restart specific service
docker restart nginx

# Access container
docker exec -it wordpress bash

# Check network connectivity
docker exec wordpress ping mariadb
```

---

## File Locations

**Host:**
- ~/data/mysql → MariaDB data
- ~/data/wordpress → WordPress files

**Container paths:**
- NGINX: /var/www/html, /etc/nginx/nginx.conf
- WordPress: /var/www/html, /run/secrets/db_password
- MariaDB: /var/lib/mysql, /run/secrets/
