# Homelab Setup

Compose-first homelab layout.

- Every app lives under `apps/<app>/`.
- Each app has its own `compose.yml`.
- Each app may have a local `.env`; real `.env` files are ignored.
- Start apps with Docker Compose from the app directory.
- Use Portainer as a UI for visibility and container operations, not as the source of truth.

## Layout

```text
apps/
  portainer/
    compose.yml
    .env

  home-assistant/
    compose.yml
    .env

  immich/
    compose.yml
    .env

  nginx-proxy-manager/
    compose.yml
    .env

  glance/
    compose.yml
    .env
    assets/
    config/

legacy/
  portainer-custom-templates/
```

## Start Portainer

```bash
cd apps/portainer
docker compose up -d
```

Open:

```text
https://localhost:9443
```

or:

```text
https://<server-ip>:9443
```

## Start an App

```bash
cd apps/<app>
docker compose up -d
```

Examples:

```bash
cd apps/home-assistant
docker compose up -d
```

```bash
cd apps/glance
docker compose up -d
```

## Portainer Visibility

Portainer can still see and operate on containers started outside Portainer because it mounts:

```text
/var/run/docker.sock
```

That means Portainer can:

- show running containers
- show logs
- inspect environment, networks, mounts, and ports
- start, stop, restart, and remove containers

Portainer will not be the source of truth for these apps unless you create Portainer stacks. For this repo, do not create Portainer stacks for normal apps. Change the app's `compose.yml` or `.env`, then redeploy with:

```bash
cd apps/<app>
docker compose up -d
```


## Firewall

Open homelab ports with UFW:

```bash
sudo ./scripts/setup-ufw.sh
```

Ports:

```text
80/tcp    Nginx Proxy Manager HTTP
443/tcp   Nginx Proxy Manager HTTPS
81/tcp    Nginx Proxy Manager admin UI
9443/tcp  Portainer HTTPS UI
8123/tcp  Home Assistant UI/API
8080/tcp  Glance dashboard
2283/tcp  Immich UI/API
```

The script does not enable UFW automatically. If this machine is remote, allow SSH before enabling UFW:

```bash
sudo ufw allow OpenSSH
sudo ufw enable
```


## Home Assistant

Home Assistant runs with `network_mode: host`.

Reason: Home Assistant discovery works best with direct host networking for SSDP, HomeKit, Chromecast, and other LAN discovery paths.

After startup:

```text
http://<server-ip>:8123
```

If you add Zigbee, Z-Wave, or another USB radio later, prefer a stable device path:

```yaml
devices:
  - /dev/serial/by-id/<device-id>:/dev/serial/by-id/<device-id>
```

## Current Apps

- Portainer: Docker management UI
- Home Assistant: home automation
- Immich: photo and video backup
- Nginx Proxy Manager: reverse proxy and Let's Encrypt UI
- Glance: personal dashboard

Pi-hole was intentionally removed.

## Notes

- Do not commit real `.env` files or secrets.
- Set `DB_PASSWORD` in `apps/immich/.env` before running Immich.
- Set `TZ` in `apps/home-assistant/.env` before running Home Assistant.
- Keep persistent app data in Docker volumes or explicit host paths.
- Back up Portainer data and app volumes separately from this repo.
