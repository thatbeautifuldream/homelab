#!/usr/bin/env sh
set -eu

# Homelab LAN service ports.
# Safe to rerun: ufw skips duplicate rules.

allow_port() {
  port="$1"
  proto="$2"
  label="$3"
  ufw allow "${port}/${proto}" comment "homelab: ${label}"
}

allow_port 80 tcp "homelab index"
allow_port 9443 tcp "portainer https"
allow_port 8123 tcp "home assistant"
allow_port 8765 tcp "glance"
allow_port 2283 tcp "immich"

ufw status verbose

cat <<'MSG'

Rules applied.
If UFW is inactive and you want to enable it, run:
  sudo ufw enable

Before enabling UFW on a remote machine, allow SSH first if needed:
  sudo ufw allow OpenSSH
MSG
