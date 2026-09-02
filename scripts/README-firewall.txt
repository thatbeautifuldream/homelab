Homelab UFW setup

Run from the repo root:

  sudo ./scripts/setup-ufw.sh

Opened ports:

  80/tcp    Homelab index
  9443/tcp  Portainer HTTPS UI
  8123/tcp  Home Assistant UI/API
  8765/tcp  Glance dashboard
  2283/tcp  Immich UI/API

The script adds rules only. It does not enable UFW automatically, because enabling UFW remotely without an SSH allow rule can lock you out.

LAN access debugging

Run on the homelab host:

  ./scripts/check-lan-access.sh

Run on another Linux/macOS client on the same network:

  ./scripts/remote-client-test.sh 192.168.1.12

If the client is Windows PowerShell:

  Test-NetConnection 192.168.1.12 -Port 9443
  Test-NetConnection 192.168.1.12 -Port 8123
