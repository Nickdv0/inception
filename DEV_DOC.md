# Developer Documentation

This document provides technical information for developers who need to set up, modify, or maintain the Inception infrastructure.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Project Architecture](#project-architecture)
3. [Building and Running](#building-and-running)
4. [Container Management](#container-management)
5. [Volume Management](#volume-management)
6. [Network Configuration](#network-configuration)
7. [Configuration Files](#configuration-files)
8. [Debugging](#debugging)
9. [Development Workflow](#development-workflow)
10. [Advanced Topics](#advanced-topics)

## Environment Setup

### Prerequisites

Install the following software before setting up the project:

- **Docker Engine** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Make** utility
- **Git** for version control
- **Text editor** (VS Code, vim, nano, etc.)

### Installation on Linux/WSL

```bash
# Update package index
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (avoid using sudo)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Clone and Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd inception

# Create necessary directories
mkdir -p srcs/requirements/{nginx,mariadb,wordpress}/{conf,tools}
mkdir -p secrets

# Create .env file
cat > srcs/.env << 'EOF'
# Domain configuration
DOMAIN_NAME=nicolas.42.fr

# Database configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=your_user_password

# WordPress configuration
WP_ADMIN_USER=admin_user
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com

# User for volume paths
USER=Nicolas
EOF

# Create secrets (if using Docker secrets)
echo "your_root_password" > secrets/db_root_password.txt
echo "your_user_password" > secrets/db_password.txt
echo "wpuser:your_user_password" > secrets/credentials.txt

# Set proper permissions
chmod 600 secrets/*
chmod 600 srcs/.env
```

### Configure Hosts File

Add domain mapping to your hosts file:

```bash
# Linux/Mac
echo "127.0.0.1 nicolas.42.fr" | sudo tee -a /etc/hosts

# Windows (run as Administrator in PowerShell)
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "127.0.0.1 nicolas.42.fr"
```

## Project Architecture

### Directory Structure

```
inception/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── USER_DOC.md                # User documentation
├── DEV_DOC.md                 # This file
├── .gitignore                 # Git ignore patterns
├── secrets/                   # Sensitive data (git-ignored)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env                   # Environment variables (git-ignored)
    ├── docker-compose.yml     # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile     # MariaDB image definition
        │   ├── .dockerignore  # Files to exclude from build
        │   ├── conf/          # MariaDB configuration files
        │   └── tools/         # Initialization scripts
        ├── nginx/
        │   ├── Dockerfile     # NGINX image definition
        │   ├── .dockerignore
        │   ├── conf/          # NGINX configuration
        │   │   └── nginx.conf
        │   └── tools/         # SSL certificate scripts
        └── wordpress/
            ├── Dockerfile     # WordPress+PHP-FPM image
            ├── .dockerignore
            ├── conf/          # PHP-FPM configuration
            └── tools/         # WordPress setup scripts
```

### Service Architecture

```
┌─────────────────────────────────────────────┐
│            External Access                   │
│         https://nicolas.42.fr:443           │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │   NGINX Container    │
        │   - SSL/TLS          │
        │   - Reverse Proxy    │
        │   - Port 443         │
        └──────────┬───────────┘
                   │ inception network
                   ▼
        ┌──────────────────────┐
        │ WordPress Container  │
        │   - PHP-FPM          │
        │   - WordPress Core   │
        └──────────┬───────────┘
                   │ inception network
                   ▼
        ┌──────────────────────┐
        │  MariaDB Container   │
        │   - MySQL Database   │
        │   - Port 3306        │
        └──────────────────────┘

Volumes:
/home/Nicolas/data/wordpress ←→ WordPress Container:/var/www/html
/home/Nicolas/data/mysql ←→ MariaDB Container:/var/lib/mysql
```

## Building and Running

### Using the Makefile

The Makefile provides convenient commands for managing the infrastructure:

```bash
# Build and start all services
make build

# Stop containers (keeps data)
make down

# Force stop containers
make kill

# Stop and remove volumes (keeps host data)
make clean

# Complete cleanup (removes everything)
make fclean

# Rebuild from scratch
make restart
```

### Makefile Breakdown

```makefile
# Get current username
USER = $(shell whoami)

# Docker compose command
DOCKER_COMPOSE=docker compose

# Path to docker-compose.yml
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

# Build target
build:
	# Create data directories on host
	mkdir -p /home/$(USER)/data/mysql
	mkdir -p /home/$(USER)/data/wordpress
	# Build and start containers
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up --build -d

# Other targets...
```

### Manual Build Process

If you need to build manually without Makefile:

```bash
# Create data directories
mkdir -p /home/Nicolas/data/{mysql,wordpress}

# Build images
cd srcs
docker compose build

# Start services
docker compose up -d

# View logs
docker compose logs -f
```

## Container Management

### Docker Compose Commands

```bash
# Start services
docker compose -f srcs/docker-compose.yml up -d

# Stop services
docker compose -f srcs/docker-compose.yml down

# View logs
docker compose -f srcs/docker-compose.yml logs -f [service_name]

# Restart a specific service
docker compose -f srcs/docker-compose.yml restart nginx

# Rebuild specific service
docker compose -f srcs/docker-compose.yml build --no-cache nginx
docker compose -f srcs/docker-compose.yml up -d nginx

# View running services
docker compose -f srcs/docker-compose.yml ps

# Execute command in running container
docker compose -f srcs/docker-compose.yml exec nginx sh
```

### Direct Docker Commands

```bash
# List all containers
docker ps -a

# View container logs
docker logs nginx
docker logs -f wordpress  # Follow logs

# Execute commands in container
docker exec -it nginx /bin/sh
docker exec -it mariadb mysql -u root -p

# Inspect container
docker inspect nginx

# View container resource usage
docker stats

# Stop/start/restart container
docker stop nginx
docker start nginx
docker restart nginx

# Remove container
docker rm nginx
```

### Container Lifecycle

1. **Build Phase**: Docker reads Dockerfile and creates image layers
2. **Create Phase**: Container is created from image
3. **Start Phase**: Container process starts (CMD or ENTRYPOINT)
4. **Running Phase**: Container is operational
5. **Stop Phase**: Container receives SIGTERM, then SIGKILL
6. **Remove Phase**: Container is deleted (image remains)

## Volume Management

### Docker Volume Commands

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect inception_mariadb_vol

# View volume data
sudo ls -la /home/Nicolas/data/mysql
sudo ls -la /home/Nicolas/data/wordpress

# Backup volume data
sudo tar -czf backup.tar.gz /home/Nicolas/data/

# Restore volume data
sudo tar -xzf backup.tar.gz -C /

# Remove volumes (dangerous!)
docker volume rm inception_mariadb_vol inception_wordpress_vol
```

### Volume Configuration in docker-compose.yml

```yaml
volumes:
  mariadb_vol:
    driver: local
    driver_opts:
      type: 'none'        # Use bind mount
      o: 'bind'           # Bind mount option
      device: '/home/${USER}/data/mysql'  # Host path
  wordpress_vol:
    driver: local
    driver_opts:
      type: 'none'
      o: 'bind'
      device: '/home/${USER}/data/wordpress'
```

### Data Persistence Locations

- **MariaDB Data**: `/home/Nicolas/data/mysql/`
  - Database files: `*.ibd`, `*.frm`
  - Binary logs: `mysql-bin.*`
  - Error log: `error.log`

- **WordPress Data**: `/home/Nicolas/data/wordpress/`
  - WordPress core files
  - `wp-content/`: themes, plugins, uploads
  - `wp-config.php`: database configuration

## Network Configuration

### Docker Network Commands

```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception_inception

# View network connections
docker network inspect inception_inception | grep -A 10 "Containers"

# Test connectivity between containers
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

### Network Configuration in docker-compose.yml

```yaml
networks:
  inception:
    driver: bridge  # Creates isolated network
```

### Container DNS Resolution

Within the `inception` network, containers can resolve each other by service name:

- `nginx` can reach `wordpress` at hostname `wordpress`
- `wordpress` can reach `mariadb` at hostname `mariadb`
- Port mapping is NOT required for inter-container communication

Example from WordPress:
```php
define('DB_HOST', 'mariadb:3306');  // Uses service name
```

## Configuration Files

### docker-compose.yml

```yaml
services:
  # NGINX Service
  web:
    build: requirements/nginx/     # Build context
    container_name: nginx          # Container name
    ports:
      - "80:80"                    # HTTP port
      - "443:443"                  # HTTPS port
    volumes:
      - wordpress_vol:/var/www/html  # Mount WordPress files
    networks:
      - inception                  # Connect to network
    restart: unless-stopped        # Restart policy
    depends_on:                    # Start order
      - app

  # WordPress Service
  app:
    build: requirements/wordpress/
    container_name: wordpress
    environment:                   # Environment variables
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - MYSQL_HOST=mariadb
    volumes:
      - wordpress_vol:/var/www/html
    networks:
      - inception
    depends_on:
      - db

  # MariaDB Service
  db:
    build: requirements/mariadb/
    container_name: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    volumes:
      - mariadb_vol:/var/lib/mysql
    networks:
      - inception

volumes:
  mariadb_vol:
    # Volume configuration...
  wordpress_vol:
    # Volume configuration...

networks:
  inception:
    driver: bridge
```

### Environment Variables (.env)

```bash
# Domain name
DOMAIN_NAME=nicolas.42.fr

# Database credentials
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=secure_user_password

# WordPress admin
WP_ADMIN_USER=admin_user
WP_ADMIN_PASSWORD=strong_password
WP_ADMIN_EMAIL=admin@example.com

# System user
USER=Nicolas
```

### Dockerfile Best Practices

**NGINX Dockerfile Example**:
```dockerfile
FROM debian:11

# Install packages in single layer
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY ./conf/nginx.conf /etc/nginx/

# Generate SSL certificate
RUN openssl req -x509 -nodes -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=nicolas.42.fr" \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt

# Expose ports
EXPOSE 80 443

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

**Key Points**:
- Use specific base image version (not `latest`)
- Combine RUN commands to reduce layers
- Clean up package cache to reduce image size
- Run process in foreground (PID 1)
- Use CMD, not ENTRYPOINT with shell scripts running infinite loops

## Debugging

### Viewing Logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Specific service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs (real-time)
docker logs -f nginx

# Last N lines
docker logs --tail 100 wordpress

# With timestamps
docker logs -t mariadb
```

### Accessing Container Shell

```bash
# Access NGINX container
docker exec -it nginx /bin/sh

# Access WordPress container
docker exec -it wordpress /bin/bash

# Access MariaDB container
docker exec -it mariadb /bin/bash
```

### Database Debugging

```bash
# Connect to MariaDB
docker exec -it mariadb mysql -u root -p

# SQL commands for debugging
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
SHOW VARIABLES LIKE 'bind%';
```

### Network Debugging

```bash
# Test connectivity from WordPress to MariaDB
docker exec wordpress ping mariadb

# Check if port is listening
docker exec mariadb netstat -tlnp

# Test HTTP connection
docker exec nginx curl http://wordpress:9000

# DNS resolution
docker exec wordpress nslookup mariadb
```

### Common Issues and Solutions

**Issue**: Container exits immediately
```bash
# Check logs for error
docker logs <container-name>

# Common causes:
# - Process runs in background (daemon mode)
# - Configuration error
# - Missing dependencies
```

**Issue**: "Cannot connect to database"
```bash
# Verify MariaDB is running
docker ps | grep mariadb

# Check MariaDB logs
docker logs mariadb

# Test connection
docker exec wordpress nc -zv mariadb 3306
```

**Issue**: Permission denied on volumes
```bash
# Check ownership
ls -la /home/Nicolas/data/

# Fix permissions
sudo chown -R Nicolas:Nicolas /home/Nicolas/data/
```

## Development Workflow

### Making Changes to Services

1. **Modify Dockerfile or configuration files**
2. **Rebuild specific service**:
   ```bash
   docker compose -f srcs/docker-compose.yml build --no-cache nginx
   ```
3. **Restart the service**:
   ```bash
   docker compose -f srcs/docker-compose.yml up -d nginx
   ```
4. **Test changes**:
   ```bash
   docker logs nginx
   curl -k https://localhost
   ```

### Testing Configuration Changes

```bash
# Test NGINX configuration syntax
docker exec nginx nginx -t

# Reload NGINX without restart
docker exec nginx nginx -s reload

# Test PHP-FPM configuration
docker exec wordpress php-fpm -t
```

### Iterative Development

```bash
# Quick rebuild and restart
make restart

# Or more granular:
make down
# Make changes to files
make build
```

## Advanced Topics

### Multi-Stage Builds

For optimized images, use multi-stage builds:

```dockerfile
# Build stage
FROM debian:11 as builder
RUN apt-get update && apt-get install -y build-essential
COPY . /src
RUN cd /src && make build

# Final stage
FROM debian:11-slim
COPY --from=builder /src/binary /usr/local/bin/
CMD ["/usr/local/bin/binary"]
```

### Health Checks

Add health checks to docker-compose.yml:

```yaml
services:
  db:
    # ... other config ...
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Resource Limits

Limit container resources:

```yaml
services:
  db:
    # ... other config ...
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          memory: 256M
```

### Custom Networks

For more complex setups:

```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

### Docker Secrets (Swarm Mode)

For production environments:

```yaml
services:
  db:
    secrets:
      - db_root_password
      - db_password

secrets:
  db_root_password:
    file: ./secrets/db_root_password.txt
  db_password:
    file: ./secrets/db_password.txt
```

Access in container at `/run/secrets/db_root_password`

### Performance Optimization

1. **Use .dockerignore**: Exclude unnecessary files from build context
2. **Minimize layers**: Combine RUN commands
3. **Use specific base images**: Avoid `latest` tag
4. **Multi-stage builds**: Keep final image small
5. **Cache dependencies**: Order Dockerfile commands properly

```dockerfile
# Bad - cache invalidated on any file change
COPY . /app
RUN npm install

# Good - cache dependencies separately
COPY package*.json /app/
RUN npm install
COPY . /app
```

## Testing

### Integration Testing

```bash
# Start services
make build

# Test NGINX
curl -k https://localhost
curl -k https://nicolas.42.fr

# Test WordPress
curl -k https://localhost/wp-admin/install.php

# Test database
docker exec mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;"

# Cleanup
make clean
```

### Automated Testing Script

```bash
#!/bin/bash
# test.sh

set -e

echo "Building services..."
make build

echo "Waiting for services to be ready..."
sleep 10

echo "Testing NGINX..."
curl -k -f https://localhost || exit 1

echo "Testing WordPress..."
docker exec wordpress test -f /var/www/html/wp-config.php || exit 1

echo "Testing MariaDB..."
docker exec mariadb mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;" || exit 1

echo "All tests passed!"
```

## Security Considerations

1. **Never commit secrets**: Use .gitignore for `.env` and `secrets/`
2. **Use strong passwords**: Generate random passwords
3. **Limit container privileges**: Avoid running as root when possible
4. **Keep images updated**: Regularly rebuild with latest base images
5. **Network isolation**: Use internal networks for services that don't need external access
6. **Read-only filesystems**: Where possible, mount volumes as read-only
7. **Security scanning**: Use tools like `docker scan` to check for vulnerabilities

```bash
# Scan image for vulnerabilities
docker scan nginx:latest
```

## Useful Docker Commands Reference

```bash
# Images
docker images                    # List images
docker rmi <image>              # Remove image
docker build -t name .          # Build image
docker image prune -a           # Remove unused images

# Containers
docker ps                       # List running containers
docker ps -a                    # List all containers
docker rm <container>           # Remove container
docker container prune          # Remove stopped containers

# System
docker system df                # Show disk usage
docker system prune -a          # Clean everything
docker info                     # System information

# Logs and debugging
docker logs <container>         # View logs
docker inspect <container>      # Detailed info
docker exec -it <container> sh  # Access shell
docker stats                    # Resource usage

# Networks
docker network ls               # List networks
docker network inspect <net>    # Network details
docker network prune            # Remove unused networks

# Volumes
docker volume ls                # List volumes
docker volume inspect <vol>     # Volume details
docker volume prune             # Remove unused volumes
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

## Contributing

When contributing to this project:

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Update documentation
5. Submit pull request with clear description

## License

This project is part of the 42 school curriculum and is intended for educational purposes.