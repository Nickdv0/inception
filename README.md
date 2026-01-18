# Inception

*This project has been created as part of the 42 curriculum by nde-vant.*

## Description

System administration project using Docker to set up NGINX, WordPress, and MariaDB in separate containers.

**Goal**: Create a multi-container infrastructure with Docker Compose.

## Instructions

### Build and Run
```bash
make build
```

### Stop
```bash
make down
```

### Access
- https://localhost or https://nde-vant.42.fr
- Admin panel: /wp-admin

### Hosts File
Add to `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
```
127.0.0.1 nde-vant.42.fr
```

## Resources

### Documentation
- [Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX](https://nginx.org/en/docs/)
- [WordPress](https://wordpress.org/documentation/)
- [MariaDB](https://mariadb.com/kb/en/documentation/)

### AI Usage
AI tools used for:
- Docker configuration syntax
- NGINX SSL/TLS setup
- Documentation structure

All content was reviewed and tested.

## Project Description

### Services
- **NGINX**: Web server with TLSv1.2/1.3, port 443 only
- **WordPress**: PHP-FPM (no web server)
- **MariaDB**: Database server

### Docker Concepts

**Virtual Machines vs Docker**
- VMs: Full OS, hardware isolation, heavy
- Docker: Shared kernel, process isolation, lightweight
- Choice: Docker for efficiency

**Secrets vs Environment Variables**
- Secrets: Encrypted, secure (requires Swarm)
- Env vars: Simple, visible in logs
- Choice: Environment variables (development)

**Docker Network vs Host Network**
- Bridge: Isolated, DNS resolution
- Host: Direct access, no isolation
- Choice: Bridge for security

**Docker Volumes vs Bind Mounts**
- Volumes: Docker-managed, portable
- Bind mounts: Direct host path
- Choice: Named volumes with bind options (for `/home/login/data/` requirement)