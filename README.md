# Homelab Setup

A simple homelab setup running self-hosted services using Docker Compose.

## Services

### Filebrowser

Web-based file management system

- Port: 8095
- Mounts: ~/Documents directory for file access on a Mac OS
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

## Usage

Each service has its own docker-compose.yml file. Navigate to the service directory and run:

```bash
docker-compose up -d
```

## Environment

- Platform: Docker
- Location: Local homelab setup
- Timezone: Asia/Kolkata
