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
  home/
    compose.yml
    .env
    public/index.html
    docker-status.sh

  portainer/
    compose.yml
    .env

  home-assistant/
    compose.yml
    .env

  immich/
    compose.yml
    .env

  glance/
    compose.yml
    .env
    assets/
    config/
  frigate/
    compose.yml
    config/config.yml
    mosquitto/config/mosquitto.conf

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

```bash
cd apps/frigate
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
80/tcp    Homelab index
9443/tcp  Portainer HTTPS UI
8123/tcp  Home Assistant UI/API
8765/tcp  Glance dashboard
2283/tcp  Immich UI/API
8971/tcp  Frigate authenticated UI/API
8555/tcp  Frigate WebRTC
8555/udp  Frigate WebRTC
```

Root index:

```text
http://<server-ip>
http://home.milind.fyi  # DNS points to this host's Tailscale IP
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

## Frigate

Frigate runs as a standalone Docker Compose app with a local Mosquitto broker for Home Assistant integration.

Open:

```text
http://<server-ip>:8971
```

Initial config:

```text
apps/frigate/config/config.yml
```

The starter config is safe to boot with `front_door.enabled: false`. After buying/configuring an RTSP-capable camera:

1. Edit `apps/frigate/config/config.yml`.
2. Replace `rtsp://user:password@192.168.1.50:554/stream1` with the camera's detect/record stream.
3. Set `front_door.enabled: true`.
4. Redeploy from `apps/frigate` with `docker compose up -d`.

Home Assistant setup:

1. Add the MQTT integration in Home Assistant with broker `127.0.0.1`, port `1883`, no username/password.
2. Install the official Frigate integration through HACS.
3. Add the Frigate integration using URL `http://127.0.0.1:5000`.
4. Use Frigate-created `camera`, `sensor`, and `binary_sensor` entities for alerts and automations.

Ports `1883`, `5000`, and `8554` are bound to localhost only. Port `8971` is the LAN UI. Port `8555` is exposed for WebRTC.

Cheap camera requirements:

- RTSP stream support.
- Prefer wired Ethernet or strong 5 GHz Wi-Fi.
- Set a lower-resolution substream around 720p/5fps for detection.
- Keep vendor cloud features disabled if the camera allows it.

This host has Intel graphics, so the config uses VAAPI decode and OpenVINO detection. If Frigate exits with `/dev/dri/renderD128` errors, verify the Intel render device exists on the Docker host.

## Home Index Status

The homelab index shows live service status derived from `docker ps`.

- The `homelab-status` sidecar runs `apps/home/docker-status.sh`.
- It snapshots `docker ps -a` into the `home_status` volume as `/status/status.ndjson`: on every container event (`docker events`) and on a `STATUS_INTERVAL` timer (default 10s).
- The index page polls `/status/status.ndjson` every 5 seconds.
- nginx only serves the generated file; the Docker socket is mounted into the sidecar, never exposed over HTTP.

To add a service to the dashboard, extend `SERVICE_DEFS` in `apps/home/public/index.html` with its container names.

## Current Apps

- Home: service index with live container status from `docker ps`
- Portainer: Docker management UI
- Home Assistant: home automation
- Immich: photo and video backup
- Glance: personal dashboard
- Frigate: local AI NVR with MQTT integration for Home Assistant

Pi-hole was intentionally removed.

## Notes

- Do not commit real `.env` files or secrets.
- Set `DB_PASSWORD` in `apps/immich/.env` before running Immich.
- Set `TZ` in `apps/home-assistant/.env` before running Home Assistant.
- Keep persistent app data in Docker volumes or explicit host paths.
- Frigate media under `apps/frigate/media/` can grow quickly; back it up separately or exclude recordings from routine backups.
- Back up Portainer data and app volumes separately from this repo.
