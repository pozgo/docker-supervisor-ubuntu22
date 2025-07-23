# polinux/supervisor-ubuntu22

A lightweight Docker image based on Ubuntu 22.04 with Supervisor process manager for running multiple services in a single container.

**Maintainer**: Przemyslaw (Ozzy) Ozgo

## Features

- **Base**: Ubuntu 22.04 LTS
- **Process Manager**: Supervisor 4.2.5
- **Interactive Mode**: TTY support with bash shell
- **Volume Support**: Persistent data storage via `/data` volume
- **Web Interface**: Supervisor web UI on port 9111
- **Configurable Credentials**: Environment variable support for authentication

## Quick Start

### Basic Usage

```bash
# Run in detached mode
docker run -d -p 9111:9111 -v /host/data:/data polinux/supervisor-ubuntu22

# Run interactively
docker run -it -p 9111:9111 -v /host/data:/data polinux/supervisor-ubuntu22
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SUPERVISOR_USERNAME` | `sv` | Username for supervisor web interface |
| `SUPERVISOR_PASSWORD` | `password` | Password for supervisor web interface |
| `SUPERVISOR_USER` | `supervisor` | Non-root user for running supervisor |
| `SUPERVISOR_UID` | `1000` | User ID for supervisor user |
| `SUPERVISOR_GID` | `1000` | Group ID for supervisor user |
| `SUPERVISOR_VERSION` | `4.2.5` | Supervisor version (build-time) |

### Custom Credentials

```bash
docker run -d \
  -e SUPERVISOR_USERNAME=admin \
  -e SUPERVISOR_PASSWORD=secure123 \
  -p 9111:9111 \
  -v /host/data:/data \
  polinux/supervisor-ubuntu22
```

## Directory Structure

```
/
├── config/
│   ├── bootstrap.sh          # Container entry point
│   └── init/                 # Custom initialization scripts
├── etc/
│   ├── supervisord.conf      # Main supervisor configuration
│   └── supervisor.d/         # Service configuration directory
└── data/                     # Persistent data volume
    ├── conf/                 # Configuration files
    ├── logs/                 # Log files
    └── run/                  # Runtime files (PIDs, sockets)
```

## Configuration

### Adding Services

Create `.conf` files in `/etc/supervisor.d/` to define services:

```ini
[program:myservice]
command=/usr/bin/myservice
directory=/opt/myservice
autostart=true
autorestart=true
user=www-data
stdout_logfile=/data/logs/myservice.log
stderr_logfile=/data/logs/myservice_error.log
```

### Initialization Scripts

Place custom initialization scripts in `/config/init/` with `.sh` extension. These run before supervisor starts:

```bash
#!/bin/bash
# /config/init/01-setup.sh
echo "Setting up application..."
# Your initialization code here
```

### Volume Mounts

The `/data` volume should be mounted for persistent storage:

- `/data/conf` - Configuration files
- `/data/logs` - Application and supervisor logs  
- `/data/run` - Runtime files (PIDs, sockets)

## Web Interface

Access the Supervisor web interface at `http://localhost:9111` using the configured credentials.

Features:
- View running processes
- Start/stop/restart services
- View logs
- Monitor resource usage

## Ports

| Port | Service |
|------|---------|
| 9111 | Supervisor web interface |

## Build Information

- **Image Optimizations**:
  - Multi-stage build practices
  - Package cache cleanup
  - Minimal package installation
  - No-cache pip installs

- **Security Features**:
  - Non-root execution where possible
  - Secure script execution (set -euo pipefail)
  - Input validation and error handling
  - Configurable authentication

## Usage Examples

### Development Environment

```bash
docker run -it \
  -p 9111:9111 \
  -v $(pwd)/config:/config/init \
  -v $(pwd)/data:/data \
  polinux/supervisor-ubuntu22
```

### Production Deployment

```bash
docker run -d \
  --name supervisor-container \
  --restart unless-stopped \
  -e SUPERVISOR_USERNAME=admin \
  -e SUPERVISOR_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) \
  -p 127.0.0.1:9111:9111 \
  -v /opt/data:/data \
  -v /opt/services:/etc/supervisor.d \
  polinux/supervisor-ubuntu22
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure the `/data` volume has correct permissions
   - Check that service users exist in the container

2. **Services Not Starting**
   - Check supervisor logs: `/data/logs/supervisord.log`
   - Verify service configuration in `/etc/supervisor.d/`

3. **Web Interface Access**
   - Ensure port 9111 is exposed and accessible
   - Check firewall settings
   - Verify credentials are correct

### Debugging

```bash
# Check supervisor status
docker exec container-name supervisorctl status

# View logs
docker exec container-name tail -f /data/logs/supervisord.log

# Interactive shell
docker exec -it container-name /bin/bash
```

## Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  supervisor:
    image: polinux/supervisor-ubuntu22
    container_name: supervisor-container
    restart: unless-stopped
    ports:
      - "9111:9111"
    environment:
      - SUPERVISOR_USERNAME=admin
      - SUPERVISOR_PASSWORD=secure123
      - SUPERVISOR_UID=1000
      - SUPERVISOR_GID=1000
    volumes:
      - ./data:/data
      - ./services:/etc/supervisor.d
      - ./init:/config/init
    networks:
      - supervisor-net

networks:
  supervisor-net:
    driver: bridge
```

Run with:
```bash
docker-compose up -d
```

## GitHub Actions CI/CD

This repository uses GitHub Actions for automated building, testing, and deployment.

### Workflow Triggers

- **Build & Test**: Triggered on every Pull Request to `main` or `dev` branches
- **Deploy**: Triggered only on GitHub releases/tags

### Required GitHub Secrets

To enable Docker Hub deployment, configure these secrets in your GitHub repository:

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token (not password) |

### Multi-Platform Support

The image is built for multiple architectures:
- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (ARM 64-bit)

## License

MIT License - see [LICENSE](LICENSE) file for details.

**Author**: Przemyslaw (Ozzy) Ozgo