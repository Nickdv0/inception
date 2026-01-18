# Developer Documentation

## Setup

### Prerequisites
- Docker
- Docker Compose
- Make

### Environment
Create `srcs/.env`:
```
DOMAIN_NAME=nde-vant.42.fr
MYSQL_ROOT_PASSWORD=rootpass
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppass
USER=croseinos
```

### Build
```bash
make build
```

## Architecture

### Services
- **NGINX** (port 443): TLSv1.2/1.3, reverse proxy
- **WordPress** (port 9000): PHP-FPM
- **MariaDB** (port 3306): Database

### Network
- Bridge: `srcs_inception`
- DNS resolution: wordpress → mariadb

### Volumes
- `srcs_mariadb_vol` → `/home/croseinos/data/mysql`
- `srcs_wordpress_vol` → `/home/croseinos/data/wordpress`

## Dockerfiles

**NGINX:**
- Base: Debian 11
- SSL self-signed cert
- Run: `nginx -g "daemon off;"`

**WordPress:**
- Base: Debian 11
- PHP-FPM + WordPress
- Run: `php-fpm7.4 -F`

**MariaDB:**
- Base: Debian 11
- Database setup
- Run: `mysqld_safe`

## Commands

### Makefile
```bash
make build    # Build and start
make down     # Stop
make clean    # Remove volumes
make fclean   # Full cleanup
make restart  # Rebuild
```

### Docker
```bash
docker ps
docker logs <container>
docker exec -it <container> /bin/sh
docker images | grep inception
```

### Verification
```bash
# Check restart policy
docker inspect nginx --format='{{.HostConfig.RestartPolicy.Name}}'

# Check SSL cert
docker exec nginx openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -noout -subject

# Check volumes
docker volume ls

# Check network
docker network ls | grep inception
```

## Data Location
- MySQL: `/home/croseinos/data/mysql/`
- WordPress: `/home/croseinos/data/wordpress/`

## Debugging

### Logs
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Network
```bash
docker network inspect srcs_inception
docker exec wordpress ping mariadb
```

### Database
```bash
docker exec mariadb mysql -u wpuser -p<password> -e "SHOW DATABASES;"
```

## Requirements
- 3 containers (nginx, wordpress, mariadb)
- Custom Dockerfiles (Debian 11)
- No "latest" tags (version 1.0)
- TLSv1.2/1.3 only
- Named volumes
- Bridge network
- Restart policy: always
- Environment variables
- Domain: login.42.fr format