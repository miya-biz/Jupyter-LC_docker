#!/usr/bin/env bash
set -euxo pipefail

JUPYTER_URL="${JUPYTER_URL:-http://localhost:8888}"
MAX_RETRIES=60
SLEEP_SECONDS=5

for attempt in $(seq 1 "${MAX_RETRIES}"); do
  if curl -vvv --fail --show-error "${JUPYTER_URL}"; then
    echo "Jupyter is accepting connections at ${JUPYTER_URL}"
    exit 0
  fi
  echo "Waiting for Jupyter... attempt ${attempt}/${MAX_RETRIES}" >&2
  sleep "${SLEEP_SECONDS}"
done

docker ps >&2 || true
>&2 echo "Timed out waiting for Jupyter at ${JUPYTER_URL}"
exit 1
