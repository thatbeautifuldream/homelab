#!/usr/bin/env sh
set -eu

HOST_IP="${1:-${HOMELAB_IP:-}}"

if [ -z "${HOST_IP}" ]; then
  HOST_IP="$(ip -4 route get 1.1.1.1 | sed -n 's/.* src \([0-9.]*\).*/\1/p')"
fi

printf 'Host IP: %s\n\n' "${HOST_IP}"

printf 'Containers:\n'
docker ps --format '  {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf '\nListening ports:\n'
ss -lntup

check_http() {
  url="$1"
  curl --noproxy '*' -k -sS -L -o /dev/null -w "  %{http_code} %{remote_ip} ${url}\n" --max-time 10 "${url}" || true
}

printf '\nLocal endpoint checks by IP:\n'
check_http "http://${HOST_IP}:80"
check_http "https://${HOST_IP}:9443"
check_http "http://${HOST_IP}:8123"

if [ "${CHECK_ALL:-0}" = "1" ]; then
  printf '\nOptional app endpoint checks by IP:\n'
  check_http "http://${HOST_IP}:8765"
  check_http "http://${HOST_IP}:2283"
fi

cat <<EOF

Run these from another device on the same network:
  ping ${HOST_IP}
  curl http://${HOST_IP}:80
  curl -k https://${HOST_IP}:9443
  curl http://${HOST_IP}:8123

If IP fails: the laptop is not on the same reachable LAN, AP/client isolation is enabled, a VPN/proxy route is intercepting traffic, or a firewall/router rule is blocking peer access.
EOF
