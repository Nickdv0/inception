# Inception

*This project has been created as part of the 42 curriculum by nde-vant.*

## Description

Docker-based infrastructure with NGINX, WordPress, and MariaDB in separate containers.

**Services:** NGINX (web server) → WordPress (PHP application) → MariaDB (database)

---

## Instructions

### Build and Run
```bash
make
```

### Access
- **With domain:** https://nde-vant.42.fr:443 (requires `/etc/hosts` entry)
- **Without domain:** https://localhost:443

**Add to /etc/hosts (optional):**
```bash
echo "127.0.0.1   nde-vant.42.fr" | sudo tee -a /etc/hosts
```

### Stop
```bash
make down
```

### Clean and Rebuild
```bash
make clean    # Clean volumes only
make fclean   # Clean volumes + Docker images
```

---


## Architecture

**Virtual Machines vs Docker:**
- Docker: Lightweight, shares kernel, fast startup
- VMs: Heavy, full OS, slow startup
- **Choice:** Docker for efficiency

**Secrets vs Environment Variables:**
- Secrets: More secure, encrypted (in /run/secrets/)
- Env vars: Simpler, visible in docker inspect
- **Choice:** Secrets for passwords, env vars for config

**Docker Network vs Host:**
- Bridge network: Isolated, DNS resolution
- Host network: Direct access, no isolation
- **Choice:** Bridge for security

**Volumes vs Bind Mounts:**
- Named volumes: Docker-managed, portable
- Bind mounts: Direct host path
- **Choice:** Named volumes with bind options

---

## Services

### NGINX (Port 8443)
- SSL/TLS encryption (self-signed certificate)
- Reverse proxy to WordPress PHP-FPM
- Static file serving

### WordPress
- WP-CLI for automated setup
- PHP-FPM 7.4
- Auto-creates admin + additional user
- Persisted in volume

### MariaDB
- Isolated database service
- Secure with secrets management
- Auto-initialization script
- Persisted in volume

---

## Credentials

Admin user: `nde-vant` (Administrator)
Regular user: `regular_user` (Author)

Passwords stored in `secrets/` directory.

---

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX](https://nginx.org/)
- [WordPress](https://wordpress.org/)
- [MariaDB](https://mariadb.com/)

**AI Usage:** Used for configuration syntax, SSL setup, and documentation structure.
