# Inception Defense Checklist

**Student:** nde-vant  
**Domain:** nde-vant.42.fr  
**Status:** ✅ READY FOR DEFENSE

---

## 🚀 Quick Start Commands

### Start Everything
```bash
cd inception
make build
```

### Stop Everything
```bash
make down
```

### Clean Everything
```bash
make fclean
```

### Access Website
- **With hosts file:** https://nde-vant.42.fr
- **Without hosts file:** https://localhost
- **Admin Panel:** https://nde-vant.42.fr/wp-admin or https://localhost/wp-admin

---

## ✅ Mandatory Requirements Checklist

### Docker Setup
- [x] Docker Compose configured
- [x] Makefile at root
- [x] All files in `srcs/` folder
- [x] Custom Dockerfiles (one per service)

### Services
- [x] NGINX with TLSv1.2/TLSv1.3 only
- [x] WordPress + PHP-FPM (no nginx)
- [x] MariaDB (no nginx)
- [x] Each service in dedicated container
- [x] All use Debian 11 base image

### Critical Requirements
- [x] **NO "latest" tags** - All images version 1.0
- [x] **Domain:** nde-vant.42.fr configured
- [x] **SSL Certificate:** CN=nde-vant.42.fr
- [x] **2 WordPress Users:** nde-vant (admin) + regular_user
- [x] **Restart policy:** `restart: always` on all containers
- [x] **Named volumes** for database and WordPress files
- [x] **Docker network:** Bridge network `srcs_inception`
- [x] **Environment variables:** Using .env file
- [x] **No passwords in Dockerfiles**
- [x] **NGINX only entrypoint** via port 443

### Documentation
- [x] README.md
- [x] USER_DOC.md
- [x] DEV_DOC.md

---

## 🧪 Commands to Show During Defense

### 1. Show Running Containers
```bash
docker ps
```
**Expected:** 3 containers (nginx, wordpress, mariadb) - all "Up"

### 2. Verify No "latest" Tags
```bash
docker images | grep inception
```
**Expected:** All show version `1.0`, NOT `latest`

### 3. Check SSL Certificate Domain
```bash
docker exec nginx openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -noout -subject
```
**Expected:** `CN = nde-vant.42.fr`

### 4. Check TLS Protocols
```bash
docker exec nginx grep ssl_protocols /etc/nginx/nginx.conf
```
**Expected:** `ssl_protocols TLSv1.2 TLSv1.3;`

### 5. Verify Restart Policy
```bash
docker inspect nginx mariadb wordpress --format='{{.Name}}: {{.HostConfig.RestartPolicy.Name}}'
```
**Expected:** All show `always`

### 6. Test Restart on Crash
```bash
docker exec nginx nginx -s stop
sleep 3
docker ps | grep nginx
```
**Expected:** nginx container automatically restarts

### 7. Show WordPress Users
```bash
docker exec mariadb mysql -u wpuser -pwppassword123 wordpress -e 'SELECT user_login FROM wp_users;'
```
**Expected:** Shows `nde-vant` and `regular_user`

### 8. Show Volumes
```bash
docker volume ls
```
**Expected:** `srcs_mariadb_vol` and `srcs_wordpress_vol`

### 9. Show Network
```bash
docker network ls | grep inception
```
**Expected:** `srcs_inception` with bridge driver

### 10. Check Data Persistence
```bash
docker volume inspect srcs_wordpress_vol --format='{{.Options.device}}'
```
**Expected:** `/home/croseinos/data/wordpress`

---

## 📋 Hosts File Setup

**Add this to hosts file:**
```
127.0.0.1 nde-vant.42.fr
```

**Windows:** `C:\Windows\System32\drivers\etc\hosts` (Run as Administrator)  
**Linux/Mac:** `/etc/hosts` (Use sudo)

**PowerShell (Windows Admin):**
```powershell
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "`n127.0.0.1 nde-vant.42.fr"
```

**Linux/Mac:**
```bash
echo "127.0.0.1 nde-vant.42.fr" | sudo tee -a /etc/hosts
```

---

## 💬 Key Questions & Answers

### Q: What's the difference between Docker and VMs?
**A:** Docker containers share the host OS kernel and provide process-level isolation. VMs run a full OS with dedicated kernel. Docker is lighter, faster to start, and uses fewer resources.

### Q: Why named volumes instead of bind mounts?
**A:** Named volumes are managed by Docker, portable, and don't depend on host directory structure. We use a hybrid approach - named volumes with bind mount options to store data in `/home/croseinos/data/` as required.

### Q: How do containers communicate?
**A:** Through the Docker bridge network `srcs_inception`. Containers resolve each other by service name (wordpress → mariadb:3306). No port mapping needed between containers.

### Q: What is PID 1 and why does it matter?
**A:** PID 1 is the first process in a container. If it exits, the container stops. All services run in foreground: nginx (`daemon off;`), php-fpm (`-F`), mysqld_safe.

### Q: Why TLSv1.2/1.3 only?
**A:** Security requirement. Older protocols have known vulnerabilities. Modern standards require TLSv1.2 minimum.

### Q: Why can't admin username be "admin"?
**A:** Security best practice. Default usernames are common brute-force targets. Using `nde-vant` is acceptable as it doesn't contain "admin" or "administrator".

---

## 🎯 WordPress Credentials

- **Admin User:** nde-vant
- **Admin Email:** nde-vant@42.fr
- **Regular User:** regular_user
- **Regular Email:** user@42.fr

---

## 📊 Project Info

- **Total Containers:** 3
- **Total Images:** 3 (all version 1.0)
- **Total Volumes:** 2 (named volumes)
- **Networks:** 1 (bridge)
- **Exposed Ports:** 80, 443 (NGINX only)

---

## ⚠️ Important Notes

1. **Use https://localhost** - Works without hosts file modification
2. **Self-signed certificate** - Browser warning is expected
3. **Data location** - `/home/croseinos/data/mysql` and `/home/croseinos/data/wordpress`
4. **Domain configured** - `nde-vant.42.fr` in SSL cert and nginx config

---

## 🔧 Troubleshooting

### Containers not running?
```bash
docker ps -a
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Need to rebuild?
```bash
make fclean
make build
```

### Check Docker status
```bash
docker info
docker ps
```

---

## ✅ Final Pre-Defense Checklist

- [ ] All containers running: `docker ps`
- [ ] No "latest" tags: `docker images | grep inception`
- [ ] Can access https://localhost
- [ ] 2 WordPress users exist
- [ ] Restart policy works
- [ ] SSL cert shows nde-vant.42.fr
- [ ] Can explain Docker vs VMs
- [ ] Can explain networking
- [ ] Can explain volumes

---

**Good luck with your defense! 🎉**