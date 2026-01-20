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
https://nde-vant.42.fr (or https://localhost)

### Stop
```bash
make down
```

---

## Requirements Met

- ✅ NGINX with TLSv1.2/1.3 only (port 443)
- ✅ WordPress + PHP-FPM (no NGINX in container)
- ✅ MariaDB (separate container)
- ✅ Two volumes (database, WordPress files)
- ✅ Docker network for container communication
- ✅ Auto-restart on crash
- ✅ Custom Dockerfiles (no pre-built images)
- ✅ Environment variables (no hardcoded passwords)

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

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX](https://nginx.org/)
- [WordPress](https://wordpress.org/)
- [MariaDB](https://mariadb.com/)

**AI Usage:** Used for configuration syntax, SSL setup, and documentation structure.
