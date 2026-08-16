# Homelab Setup

Portainer-first homelab setup. The only container managed directly from this repository is Portainer Community Edition; homelab apps are exposed as custom Portainer App Templates.

## Portainer

Community Edition Docker management UI for creating and managing containers, stacks, volumes, networks, and logs.

- Port: 9443 (HTTPS)
- Data: Stored in the `portainer_data` Docker volume
- Template source: `portainer/templates/templates-2.0.json`

## Custom App Templates

The custom template catalog currently includes:

- Immich: self-hosted photo and video backup
- Nginx Proxy Manager: reverse proxy and Let's Encrypt UI
- Glance: personal dashboard

Pi-hole was intentionally removed.

## Usage

Start Portainer:

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

The Portainer container is started with `--templates`, pointing at the raw GitHub URL for this repo's custom template file. On a fresh system, Portainer loads those templates during first startup.

For an existing Portainer install, create an API access token in **My account -> Access tokens**, then run:

```bash
cd portainer
PORTAINER_API_KEY=<token> ./apply-templates.sh
```

Optional overrides:

```bash
PORTAINER_URL=https://portainer.example.com:9443 \
TEMPLATES_URL=https://raw.githubusercontent.com/thatbeautifuldream/homelab/main/portainer/templates/templates-2.0.json \
PORTAINER_API_KEY=<token> \
./apply-templates.sh
```

## Template Development

Template catalog:

```text
portainer/templates/templates-2.0.json
```

Stack files:

```text
portainer/templates/stacks/immich/docker-compose.yml
portainer/templates/stacks/nginx-proxy-manager/docker-compose.yml
portainer/templates/stacks/glance/docker-compose.yml
```

Portainer stack templates must reference a public Git repository and a stack file path inside that repository.

## Environment

- Platform: Docker
- Location: Local homelab setup
- Architecture: Portainer-managed containerized deployment
