# User Documentation

This document provides instructions for end users and administrators on how to use and manage the Inception infrastructure.

## Overview

The Inception project provides a complete web hosting stack consisting of:
- **NGINX Web Server**: Handles HTTPS requests and serves as the entry point
- **WordPress**: Content management system for creating and managing website content
- **MariaDB**: Database system that stores all WordPress data

## Getting Started

### Prerequisites

Before using this system, ensure:
- Docker and Docker Compose are installed on your machine
- You have access to the project directory
- You have permissions to run Docker commands (may require sudo)
- Your system has at least 2GB of free RAM and 10GB of disk space

### Starting the Services

To start all services, navigate to the project root directory and run:

```bash
make build
```

This command will:
1. Create data directories at `/home/Nicolas/data/mysql` and `/home/Nicolas/data/wordpress`
2. Build Docker images for all services
3. Start all containers in the background
4. Set up the network and volumes

**Expected output**: You should see Docker building images and starting containers. The process takes 1-3 minutes on first run.

### Stopping the Services

To stop all running services:

```bash
make down
```

This stops all containers but preserves your data (database and website files).

### Restarting the Services

If you need to restart the services:

```bash
make restart
```

This will stop containers, remove volumes, and rebuild everything from scratch.

## Accessing the Website

### Main Website

Once the services are running, access your WordPress website at:

- **URL**: https://nicolas.42.fr
- **Alternative**: https://localhost

**Important**: Since the project uses a self-signed SSL certificate, your browser will display a security warning. This is expected behavior. To proceed:

1. Click "Advanced" or "Show Details"
2. Click "Accept the Risk" or "Proceed to site"

### WordPress Administration Panel

To manage your website content:

1. Navigate to: https://nicolas.42.fr/wp-admin
2. Log in with your WordPress credentials

**Default credentials** (if configured during setup):
- Username: (check your `.env` file or ask the administrator)
- Password: (stored in secrets or `.env` file)

### First-Time WordPress Setup

If WordPress hasn't been configured yet, you'll see the installation wizard:

1. Select your language
2. Create an administrator account:
   - Choose a username (avoid "admin" or "administrator")
   - Use a strong password
   - Provide a valid email address
3. Click "Install WordPress"
4. Log in with your new credentials

## Managing Credentials

### Location of Credentials

Credentials are stored in two locations:

1. **Environment Variables** (`srcs/.env`):
   - Database name
   - Database username
   - Database password
   - Domain name

2. **Secrets Directory** (`secrets/`):
   - `db_root_password.txt` - MariaDB root password
   - `db_password.txt` - MariaDB user password
   - `credentials.txt` - Additional credentials

**Security Note**: Never commit these files to version control (Git). They should be listed in `.gitignore`.

### Viewing Credentials

To view database credentials:

```bash
cat srcs/.env
```

To view secret files:

```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
```

### Changing Passwords

If you need to change passwords:

1. Stop the services: `make down`
2. Edit the `.env` file or secret files
3. Remove existing data: `make clean`
4. Rebuild: `make build`

**Warning**: Changing passwords after initial setup will require recreating the database.

## Verifying Services

### Check Running Containers

To verify all containers are running:

```bash
docker ps
```

You should see three containers:
- `nginx` (port 443)
- `wordpress`
- `mariadb`

All containers should show status "Up" with uptime.

### Check Container Logs

To view logs for troubleshooting:

**NGINX logs**:
```bash
docker logs nginx
```

**WordPress logs**:
```bash
docker logs wordpress
```

**MariaDB logs**:
```bash
docker logs mariadb
```

### Check Service Health

**Test NGINX**:
```bash
curl -k https://localhost
```
You should receive HTML content from WordPress.

**Test Database Connection**:
```bash
docker exec -it mariadb mysql -u root -p
```
Enter the root password when prompted. If successful, you'll see the MariaDB prompt.

**Test WordPress**:
Open your browser and navigate to https://nicolas.42.fr. You should see your WordPress site.

### Verify Data Persistence

Check that data directories exist and contain files:

```bash
ls -la /home/Nicolas/data/mysql
ls -la /home/Nicolas/data/wordpress
```

Both directories should contain files and subdirectories.

## Common Administrative Tasks

### Backing Up Data

To back up your website and database:

1. Stop the services: `make down`
2. Copy the data directories:
```bash
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/Nicolas/data/
```
3. Restart services: `make build`

### Restoring from Backup

1. Stop services: `make down`
2. Remove current data: `make clean`
3. Extract backup:
```bash
sudo tar -xzf backup-YYYYMMDD.tar.gz -C /
```
4. Restart services: `make build`

### Updating WordPress

WordPress updates can be performed through the admin panel:

1. Log in to https://nicolas.42.fr/wp-admin
2. Navigate to Dashboard → Updates
3. Click "Update Now" for WordPress core, themes, or plugins

### Installing WordPress Plugins/Themes

1. Log in to WordPress admin panel
2. Navigate to Plugins → Add New or Appearance → Themes → Add New
3. Search for desired plugin/theme
4. Click "Install" then "Activate"

### Viewing Resource Usage

Check how much resources the containers are using:

```bash
docker stats
```

This shows real-time CPU, memory, and network usage for each container.

## Troubleshooting

### Services Won't Start

**Problem**: Containers exit immediately after starting.

**Solution**:
1. Check logs: `docker logs <container-name>`
2. Verify environment variables: `cat srcs/.env`
3. Ensure ports 80 and 443 are not in use: `sudo netstat -tlnp | grep -E ':(80|443)'`
4. Try rebuilding: `make fclean && make build`

### Cannot Access Website

**Problem**: Browser shows "Connection refused" or timeout.

**Solution**:
1. Verify containers are running: `docker ps`
2. Check NGINX logs: `docker logs nginx`
3. Verify domain in `/etc/hosts`: `cat /etc/hosts | grep nicolas.42.fr`
4. Try accessing via IP: `https://localhost`

### Database Connection Errors

**Problem**: WordPress shows "Error establishing database connection".

**Solution**:
1. Check MariaDB is running: `docker ps | grep mariadb`
2. Verify database credentials match in `.env` and WordPress
3. Check MariaDB logs: `docker logs mariadb`
4. Restart services: `make restart`

### Permission Denied Errors

**Problem**: Cannot create data directories or write files.

**Solution**:
1. Run make with sudo: `sudo make build`
2. Check directory permissions:
```bash
ls -la /home/Nicolas/data/
```
3. Fix permissions if needed:
```bash
sudo chown -R Nicolas:Nicolas /home/Nicolas/data/
```

### SSL Certificate Warnings

**Problem**: Browser shows "Your connection is not private".

**Solution**: This is expected with self-signed certificates. Click "Advanced" and proceed to the site. For production, use a certificate from Let's Encrypt or a trusted CA.

## Maintenance

### Regular Maintenance Tasks

**Weekly**:
- Check container logs for errors
- Verify backup integrity
- Update WordPress plugins and themes

**Monthly**:
- Review disk space: `df -h /home/Nicolas/data/`
- Check for WordPress core updates
- Rotate old log files if needed

**As Needed**:
- Update Docker images: `make fclean && make build`
- Review and update environment variables
- Test backup restoration process

### Cleaning Up

**Remove stopped containers and old images**:
```bash
docker system prune -a
```

**Complete cleanup** (removes all data):
```bash
make fclean
```

**Warning**: This deletes all website content and database data permanently!

## Security Best Practices

1. **Use Strong Passwords**: Ensure all passwords are complex and unique
2. **Regular Updates**: Keep WordPress, plugins, and themes updated
3. **Limit Admin Access**: Create separate user accounts for different roles
4. **Monitor Logs**: Regularly check logs for suspicious activity
5. **Backup Regularly**: Maintain multiple backup copies in different locations
6. **Use HTTPS Only**: Never access the site over HTTP (port 80 should redirect to 443)

## Support and Additional Information

For technical details and development information, see:
- `DEV_DOC.md` - Developer documentation
- `README.md` - Project overview and technical choices

For issues or questions, contact your system administrator or refer to the official documentation:
- Docker: https://docs.docker.com/
- WordPress: https://wordpress.org/support/
- NGINX: https://nginx.org/en/docs/