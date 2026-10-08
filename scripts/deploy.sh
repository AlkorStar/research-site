#!/usr/bin/env bash
# Деплой статики на Helios по rsync с healthcheck и preview-сборками.
set -euo pipefail

HOST="${HELIOS_HOST:?HELIOS_HOST not set}"
USER="${HELIOS_USER:?HELIOS_USER not set}"
REMOTE_BASE="${HELIOS_PATH:?HELIOS_PATH not set}"
BRANCH="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"
SRC="${1:-_build/html/}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  TARGET="$REMOTE_BASE/current"
  RELEASE_DIR="$REMOTE_BASE/releases/$TIMESTAMP"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  TARGET="$REMOTE_BASE/preview/$SAFE_BRANCH"
  RELEASE_DIR=""
fi

echo ">>> Deploy $SRC → $USER@$HOST:$TARGET"

if [ -n "$RELEASE_DIR" ]; then
  ssh "$USER@$HOST" "
    set -e
    mkdir -p '$REMOTE_BASE/releases'
    if [ -d '$REMOTE_BASE/current' ]; then
      cp -a '$REMOTE_BASE/current' '$RELEASE_DIR'
      echo 'Saved release: $RELEASE_DIR'
    fi
    mkdir -p '$TARGET'
  "
fi

rsync -avz --delete \
  -e "ssh -i ~/.ssh/id_ed25519 -o UserKnownHostsFile=~/.ssh/known_hosts" \
  "$SRC" "$USER@$HOST:$TARGET/"

if [ -n "${HELIOS_URL:-}" ]; then
  echo ">>> Healthcheck $HELIOS_URL"
  BODY=$(curl -fsS "$HELIOS_URL" || true)
  if ! echo "$BODY" | grep -q "${HEALTHCHECK_STRING:-Результаты исследования}"; then
    echo "!!! Healthcheck failed"
    exit 1
  fi
  echo ">>> Healthcheck OK"
fi

echo ">>> Deploy done"