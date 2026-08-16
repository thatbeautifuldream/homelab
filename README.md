# Homelab Setup

A comprehensive homelab setup running self-hosted services using Docker Compose.

## Services

### Immich

Self-hosted photo and video backup solution

- Port: 2283
- Features: Photo management, backup, and sharing
- Components:
  - Main application server
  - Machine learning for image recognition
  - Redis for caching
  - PostgreSQL database

### Nginx Proxy Manager

Dockerized reverse proxy with web UI

- Ports: 80 (HTTP), 443 (HTTPS), 81 (Admin)
- Features: SSL certificate management, proxy hosts

### Pi-hole

Network-wide ad blocking and DNS server

- Ports: 53 (DNS), 80 (HTTP), 443 (HTTPS)
- Features: Ad blocking, DNS filtering, web interface

### Portainer

Community Edition Docker management UI for creating and managing containers

- Port: 9443 (HTTPS)
- Features: Local Docker environment management, stacks, volumes, networks, container logs
- Data: Stored in the `portainer_data` Docker volume

## Usage

Each service has its own docker-compose.yml file. Navigate to the service directory and run:

```bash
docker-compose up -d
```

## Environment

- Platform: Docker
- Location: Local homelab setup
- Architecture: Multi-service containerized deployment
