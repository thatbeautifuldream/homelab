#!/usr/bin/env sh
set -eu

PORTAINER_URL="${PORTAINER_URL:-https://localhost:9443}"
REPOSITORY_URL="${REPOSITORY_URL:-https://github.com/thatbeautifuldream/homelab.git}"
REPOSITORY_REFERENCE_NAME="${REPOSITORY_REFERENCE_NAME:-refs/heads/main}"
CUSTOM_TEMPLATES_FILE="${CUSTOM_TEMPLATES_FILE:-./custom-templates.json}"
RESTORE_DEFAULT_APP_TEMPLATES="${RESTORE_DEFAULT_APP_TEMPLATES:-true}"
DEFAULT_APP_TEMPLATES_URL="${DEFAULT_APP_TEMPLATES_URL:-https://raw.githubusercontent.com/portainer/templates/master/templates-2.0.json}"

if [ -n "${PORTAINER_API_KEY:-}" ]; then
  AUTH_HEADER_NAME="X-API-Key"
  AUTH_HEADER_VALUE="${PORTAINER_API_KEY}"
elif [ -n "${PORTAINER_JWT:-}" ]; then
  AUTH_HEADER_NAME="Authorization"
  AUTH_HEADER_VALUE="Bearer ${PORTAINER_JWT}"
else
  echo "PORTAINER_API_KEY or PORTAINER_JWT is required. Create an API key in Portainer: My account -> Access tokens." >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if [ ! -f "${CUSTOM_TEMPLATES_FILE}" ]; then
  echo "Custom template manifest not found: ${CUSTOM_TEMPLATES_FILE}" >&2
  exit 1
fi

api_get() {
  curl -kfsS -H "${AUTH_HEADER_NAME}: ${AUTH_HEADER_VALUE}" "$1"
}

api_delete() {
  curl -kfsS -X DELETE -H "${AUTH_HEADER_NAME}: ${AUTH_HEADER_VALUE}" "$1" >/dev/null
}

api_post_json() {
  curl -kfsS -X POST \
    -H "${AUTH_HEADER_NAME}: ${AUTH_HEADER_VALUE}" \
    -H "Content-Type: application/json" \
    --data-binary "$2" \
    "$1" >/dev/null
}

api_put_json() {
  curl -kfsS -X PUT \
    -H "${AUTH_HEADER_NAME}: ${AUTH_HEADER_VALUE}" \
    -H "Content-Type: application/json" \
    --data-binary "$2" \
    "$1" >/dev/null
}

if [ "${RESTORE_DEFAULT_APP_TEMPLATES}" = "true" ]; then
  settings="$(api_get "${PORTAINER_URL}/api/settings")"
  updated_settings="$(printf '%s' "${settings}" | jq --arg url "${DEFAULT_APP_TEMPLATES_URL}" '.TemplatesURL = $url')"
  api_put_json "${PORTAINER_URL}/api/settings" "${updated_settings}"
  echo "App Templates URL restored to Portainer default: ${DEFAULT_APP_TEMPLATES_URL}"
fi

existing_templates="$(api_get "${PORTAINER_URL}/api/custom_templates")"

jq -c \
  --arg repository_url "${REPOSITORY_URL}" \
  --arg repository_reference_name "${REPOSITORY_REFERENCE_NAME}" \
  '.[] | .RepositoryURL = $repository_url | .RepositoryReferenceName = $repository_reference_name' \
  "${CUSTOM_TEMPLATES_FILE}" |
while IFS= read -r template; do
  title="$(printf '%s' "${template}" | jq -r '.Title')"

  printf '%s' "${existing_templates}" \
    | jq -r --arg title "${title}" '.[] | select(.Title == $title) | .Id' \
    | while IFS= read -r id; do
        if [ -n "${id}" ]; then
          api_delete "${PORTAINER_URL}/api/custom_templates/${id}"
          echo "Deleted existing custom template: ${title} (${id})"
        fi
      done

  api_post_json "${PORTAINER_URL}/api/custom_templates/create/repository" "${template}"
  echo "Created custom template: ${title}"
done

echo "Done. Open Portainer -> Templates -> Custom."
