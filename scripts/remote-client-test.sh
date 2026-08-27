#!/usr/bin/env sh
set -eu

HOST_IP="${1:-192.168.1.12}"

check() {
  url="$1"
  curl --noproxy '*' -k -sS -L -o /dev/null -w "%{http_code} %{remote_ip} ${url}\n" --max-time 10 "${url}" || true
}

printf 'Testing homelab host by IP: %s\n' "${HOST_IP}"
check "http://${HOST_IP}:80"
check "https://${HOST_IP}:9443"
check "http://${HOST_IP}:8123"

cat <<EOF

Expected browser URLs:
  http://${HOST_IP}
  https://${HOST_IP}:9443
  http://${HOST_IP}:8123

If IP fails: not same reachable LAN, AP/client isolation, VPN/proxy route, or firewall/router block.
EOF
