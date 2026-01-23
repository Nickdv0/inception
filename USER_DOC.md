# User Documentation

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Ports 8443 available
- (Optional) Add domain to /etc/hosts

### Start Services
```bash
make
```

### Access Website
- **With domain:** https://nde-vant.42.fr:443
- **Without domain:** https://localhost:443
- **Admin panel:** Add `/wp-admin` to either URL

**Add domain (optional):**
```bash
echo "127.0.0.1   nde-vant.42.fr" | sudo tee -a /etc/hosts
```

(Accept browser security warning for self-signed certificate)

---

## WordPress Setup

**Automatic Setup:**
WordPress is automatically configured on first run with:
- Admin user: `nde-vant` (Administrator role)
- Additional user: `regular_user` (Author role)

**Passwords:**
Check `secrets/wp_admin_password.txt` and `secrets/wp_user_password.txt`

**Manual User Management:**
1. Login as admin
2. Go to Users → Add New
3. Create additional users as needed

---

## Manage Services

### Check Status
```bash
docker ps
```
All three containers should show "Up": nginx, wordpress, mariadb

### View Logs
```bash
docker logs nginx       # Web server logs
docker logs wordpress   # PHP-FPM and WP-CLI logs
docker logs mariadb     # Database initialization logs
```

### Stop Services
```bash
make down
```

### Restart Services
```bash
make re
```

### Clean Volumes
```bash
make clean     # Clean data volumes only
make fclean    # Clean volumes + remove images
```

---

## Troubleshooting

**Site not accessible:**
```bash
docker ps                    # Check containers are running
docker logs nginx            # Check for errors
curl -k https://localhost:8443  # Test from command line
make re                      # Rebuild if needed
```

**WordPress not installed:**
```bash
docker logs wordpress        # Check initialization logs
docker exec wordpress wp user list --path=/var/www/html --allow-root  # Verify users
```

**Database connection issues:**
```bash
docker logs mariadb          # Check database logs
docker exec mariadb mysql -u wpuser -p"$(cat secrets/db_password.txt)" -e "SHOW DATABASES;"
```

**Reset everything:**
```bash
make fclean    # Remove all data and images
make           # Rebuild from scratch
```

---

## Data Persistence

Data is stored in:
- WordPress files: `~/data/wordpress/`
- Database files: `~/data/mysql/`

These directories persist between container restarts.
