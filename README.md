# Homelab Setup

A comprehensive homelab setup running self-hosted services using Docker Compose.

## Services

### Dokploy

Platform as a Service (PaaS) for deploying applications

- Port: 3000
- Components:
  - Main application server
  - PostgreSQL database
  - Redis for caching
  - Traefik reverse proxy (ports 80, 443)

### Filebrowser

Web-based file management system

- Port: 8095
- Mounts: ~/Documents directory for file access
- Configuration: Custom settings and database stored locally

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

## Usage

Each service has its own docker-compose.yml file. Navigate to the service directory and run:

```bash
docker-compose up -d
```

## Environment

- Platform: Docker
- Location: Local homelab setup
- Architecture: Multi-service containerized deployment
