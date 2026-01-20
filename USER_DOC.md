# User Documentation

## Quick Start

### Start Services
```bash
make
```

### Access Website
- URL: https://nde-vant.42.fr
- Admin: https://nde-vant.42.fr/wp-admin

(Accept browser security warning for self-signed certificate)

---

## Setup WordPress

1. Visit https://nde-vant.42.fr
2. Select language
3. Create admin user (username cannot be "admin" or "administrator")
4. Login and create second user (Users → Add New)

---

## Manage Services

### Check Status
```bash
docker ps
```
All three containers should show "Up"

### View Logs
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Stop Services
```bash
make down
```

### Restart Services
```bash
make re
```

---

## Troubleshooting

**Site not accessible:**
```bash
docker ps              # Check containers are running
docker logs nginx      # Check for errors
make re                # Rebuild
```

**Forgot admin password:**
Access database and reset via WordPress admin panel, or rebuild:
```bash
make fclean
make
```
