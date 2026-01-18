# Inception

*This project has been created as part of the 42 curriculum by Nicolas.*

## Description

Inception is a System Administration project that focuses on virtualization and containerization using Docker. The goal is to set up a small infrastructure composed of different services (NGINX, WordPress, and MariaDB) running in separate Docker containers, orchestrated with Docker Compose.

This project demonstrates understanding of:
- Docker containerization and image creation
- Docker Compose for multi-container orchestration
- Docker networking and volumes
- Service configuration and deployment
- SSL/TLS security implementation
- Environment variable management and secrets handling

The infrastructure consists of:
- **NGINX**: Web server with TLSv1.2/TLSv1.3 support acting as the entry point
- **WordPress**: Content management system with PHP-FPM
- **MariaDB**: Database server for WordPress data persistence

All services run in isolated containers connected through a Docker network, with persistent data stored in Docker volumes.

## Instructions

### Prerequisites

- A Linux-based Virtual Machine (or WSL2 on Windows)
- Docker and Docker Compose installed
- Make utility
- Root or sudo privileges to create directories in `/home/Nicolas/data`

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Set up environment variables:
   - Ensure `srcs/.env` file exists with required variables
   - Configure secrets files in the `secrets/` directory (if used)

3. Update your hosts file to point your domain to localhost:
```bash
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
127.0.0.1 nde-vant.42.fr
```

### Running the Project

Build and start all services:
```bash
make build
```

This command will:
- Create necessary directories at `/home/Nicolas/data/`
- Build Docker images from Dockerfiles
- Start all containers in detached mode

### Other Makefile Commands

- `make down` - Stop all containers
- `make kill` - Force stop all containers
- `make clean` - Stop containers and remove volumes
- `make fclean` - Complete cleanup (removes all data)
- `make restart` - Clean and rebuild everything

### Accessing Services

- **WordPress Website**: https://nde-vant.42.fr (or https://localhost)
- **WordPress Admin**: https://nde-vant.42.fr/wp-admin

**Note**: Your browser will warn about the self-signed SSL certificate. This is expected for development environments.

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Tutorials
- [Docker Getting Started Guide](https://docs.docker.com/get-started/)
- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)
- [Setting up SSL/TLS with NGINX](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI Usage

AI tools (such as ChatGPT, Claude, and GitHub Copilot) were used in this project for the following purposes:

1. **Documentation Research**: 
   - Understanding Docker best practices and PID 1 requirements
   - Learning about Docker Compose syntax and configuration options
   - Researching NGINX SSL/TLS configuration

2. **Configuration File Structure**:
   - Generating initial templates for configuration files
   - Understanding proper syntax for docker-compose.yml
   - Learning environment variable substitution patterns

3. **Troubleshooting**:
   - Debugging container startup issues
   - Understanding Docker networking concepts
   - Resolving volume mount permissions

4. **Documentation Writing**:
   - Structuring README files according to best practices
   - Generating clear user and developer documentation
   - Creating comprehensive command references

**Important Note**: All AI-generated content was thoroughly reviewed, tested, and adapted to the specific requirements of this project. The core logic, architecture decisions, and implementation details were developed with full understanding and can be explained and defended during evaluation.

## Project Structure

```
inception/
├── Makefile              # Build automation
├── secrets/              # Sensitive credentials (git-ignored)
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── .env             # Environment variables (git-ignored)
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/
│       │   └── tools/
│       └── wordpress/
│           ├── Dockerfile
│           ├── conf/
│           └── tools/
├── README.md            # This file
├── USER_DOC.md          # User documentation
└── DEV_DOC.md           # Developer documentation
```

## Technical Choices

### Virtual Machines vs Docker

**Virtual Machines (VMs)**:
- Run a complete operating system with dedicated kernel
- Provide hardware-level isolation
- Higher resource overhead (CPU, RAM, storage)
- Slower startup times (minutes)
- Better for running different OS types

**Docker Containers**:
- Share the host OS kernel
- Process-level isolation using namespaces and cgroups
- Minimal resource overhead
- Fast startup times (seconds)
- Ideal for microservices architecture
- Better for development and deployment consistency

**Choice**: Docker was chosen for this project because it provides lightweight, fast, and reproducible environments perfect for deploying multiple services with minimal overhead.

### Secrets vs Environment Variables

**Environment Variables**:
- Stored in `.env` file or shell environment
- Easy to use and widely supported
- Visible in container inspection (`docker inspect`)
- Can appear in logs or error messages
- Suitable for non-sensitive configuration

**Docker Secrets**:
- Encrypted during transit and at rest in swarm mode
- Only available to services that have been granted access
- Mounted as files in `/run/secrets/`
- Never stored in environment or logs
- Require Docker Swarm or Kubernetes

**Choice**: This project uses environment variables for simplicity in development, but in production, Docker secrets should be used for sensitive data like passwords and API keys.

### Docker Network vs Host Network

**Docker Bridge Network**:
- Containers get isolated network namespace
- Internal DNS resolution between containers
- Explicit port mapping required for external access
- Better security through isolation
- Allows multiple containers to use same ports internally

**Host Network**:
- Container shares host's network namespace
- No network isolation
- Direct access to all host network interfaces
- No port mapping needed
- Performance benefits but security concerns

**Choice**: Docker bridge network (`inception`) is used to provide isolation while allowing containers to communicate via service names (e.g., `mariadb`), following microservices best practices.

### Docker Volumes vs Bind Mounts

**Docker Volumes**:
- Managed by Docker in `/var/lib/docker/volumes/`
- Created and managed via Docker API
- Can be named and reused across containers
- Backup and migration utilities available
- Works across different host systems

**Bind Mounts**:
- Map specific host directory to container
- Full access to host filesystem
- Dependent on host directory structure
- Better for development (live code updates)
- More control over exact location

**Choice**: This project uses named Docker volumes with bind mount configuration to satisfy the requirement of storing data in `/home/Nicolas/data/` while maintaining Docker volume management benefits. This hybrid approach provides both explicit data location and Docker's volume management features.

## License

This project is part of the 42 school curriculum and is intended for educational purposes.