#!/bin/sh
# Generates status.ndjson consumed by the homelab index page.
#
# Output: one JSON object per line (NDJSON):
#   {"generatedAt":"<utc iso8601>"}
#   {"Names":"<container>","State":"running","Status":"Up 5 minutes (healthy)",...}
#
# Refresh cadence:
#   - immediately on every container event (docker events)
#   - on a timer as fallback (STATUS_INTERVAL, default 10s)
#
# Writes are atomic: tmp file + mv, so readers never see a torn file.
set -u

OUT_DIR="${STATUS_DIR:-/status-out}"
INTERVAL="${STATUS_INTERVAL:-10}"
DEST="${OUT_DIR}/status.ndjson"

snapshot() {
  tmp="${DEST}.tmp.$$"
  {
    printf '{"generatedAt":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    docker ps -a --format '{{json .}}' 2>/dev/null || true
  } > "${tmp}" 2>/dev/null || true
  mv -f "${tmp}" "${DEST}" 2>/dev/null || true
}

mkdir -p "${OUT_DIR}"

# Event-driven refresh: snapshot as soon as container state changes.
(
  while true; do
    docker events --filter type=container --format 'x' 2>/dev/null \
      | while IFS= read -r _event; do snapshot; done
    sleep 5
  done
) &

# Periodic fallback refresh.
while true; do
  snapshot
  sleep "${INTERVAL}"
done
