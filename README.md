# Homelab Setup

Simple Portainer-managed homelab.

- Run **Portainer** directly from this repo.
- Keep app Compose files in `stacks/` as the source of truth.
- Register those apps as Portainer **Custom Templates** for easy launching.
- Keep Portainer's built-in App Templates unchanged.

## Layout

```text
portainer/
  docker-compose.yml            # Portainer CE only
  custom-templates.json         # Custom template metadata
  apply-custom-templates.sh     # Syncs custom templates into Portainer

stacks/
  immich/compose.yaml
  nginx-proxy-manager/compose.yaml
  glance/compose.yaml
```

## Start Portainer

```bash
cd portainer
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

## Sync Custom Templates

Create an API key in Portainer:

```text
My account -> Access tokens
```

Then run:

```bash
cd portainer
PORTAINER_API_KEY=<token> ./apply-custom-templates.sh
```

Custom templates appear here:

```text
https://localhost:9443/#!/3/docker/templates/custom
```

The script is safe to rerun. It deletes/recreates only these custom templates by title:

- Immich
- Nginx Proxy Manager
- Glance

It also restores Portainer's built-in App Templates URL to the default:

```text
https://raw.githubusercontent.com/portainer/templates/master/templates-2.0.json
```

## Recommended Use

Use **Custom Templates** to launch apps quickly.

For apps you care about long-term, create them as **Git-backed Portainer Stacks**:

```text
Stacks -> Add stack -> Git repository
Repository URL: https://github.com/thatbeautifuldream/homelab.git
Repository reference: refs/heads/main
Compose path: stacks/<app>/compose.yaml
```

That keeps Git as the source of truth while Portainer manages containers.

## Current Apps

- Immich: photo and video backup
- Nginx Proxy Manager: reverse proxy and Let's Encrypt UI
- Glance: personal dashboard

Pi-hole was intentionally removed.

## Notes

- Do not commit real `.env` files or secrets.
- Keep persistent app data in Docker volumes or explicit host paths.
- Back up Portainer data and app volumes separately from this repo.
