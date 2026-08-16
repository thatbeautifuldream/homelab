#!/usr/bin/env sh
set -eu

PORTAINER_URL="${PORTAINER_URL:-https://localhost:9443}"
TEMPLATES_URL="${TEMPLATES_URL:-https://raw.githubusercontent.com/thatbeautifuldream/homelab/main/portainer/templates/templates-2.0.json}"

if [ -z "${PORTAINER_API_KEY:-}" ]; then
  echo "PORTAINER_API_KEY is required. Create one in Portainer: My account -> Access tokens." >&2
  exit 1
fi

settings="$(curl -kfsS \
  -H "X-API-Key: ${PORTAINER_API_KEY}" \
  "${PORTAINER_URL}/api/settings")"

printf '%s' "${settings}" \
  | jq --arg templates_url "${TEMPLATES_URL}" '.TemplatesURL = $templates_url' \
  | curl -kfsS -X PUT \
      -H "X-API-Key: ${PORTAINER_API_KEY}" \
      -H "Content-Type: application/json" \
      --data-binary @- \
      "${PORTAINER_URL}/api/settings" >/dev/null

curl -kfsS \
  -H "X-API-Key: ${PORTAINER_API_KEY}" \
  "${PORTAINER_URL}/api/settings" \
  | jq -r '.TemplatesURL'
