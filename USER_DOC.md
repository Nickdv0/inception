# User Documentation

## Start/Stop

**Start:**
```bash
make build
```

**Stop:**
```bash
make down
```

## Access

- Website: https://localhost
- Admin: https://localhost/wp-admin

## Setup

### 1. Add Domain (Optional)
Add to hosts file:
```
127.0.0.1 nde-vant.42.fr
```

**Location:**
- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Linux/Mac: `/etc/hosts`

### 2. Install WordPress
1. Visit https://localhost
2. Follow wizard
3. Create admin (not "admin")
4. Users → Add New (create second user)

## Manage

### Check Status
```bash
docker ps
```

### View Logs
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Credentials
Location: `srcs/.env`

### Restart
```bash
make restart
```

## Troubleshooting

**Containers not running:**
```bash
docker ps -a
docker logs <container>
make restart
```

**Cannot access site:**
- Check: `docker ps`
- Try: https://localhost