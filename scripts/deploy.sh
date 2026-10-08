#!/usr/bin/env bash
# Деплой статики на Helios по rsync с healthcheck и preview-сборками.
set -euo pipefail

HOST="${HELIOS_HOST:?HELIOS_HOST not set}"
PORT="${HELIOS_PORT:-22}"
USER="${HELIOS_USER:?HELIOS_USER not set}"
REMOTE_BASE="${HELIOS_PATH:?HELIOS_PATH not set}"
BRANCH="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"
SRC="${1:-_build/html/}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Куда деплоим
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  TARGET="$REMOTE_BASE"
  RELEASE_DIR="$REMOTE_BASE/releases/$TIMESTAMP"
else
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  TARGET="$REMOTE_BASE/preview/$SAFE_BRANCH"
  RELEASE_DIR=""
fi

echo ">>> Deploy $SRC → $USER@$HOST:$PORT:$TARGET"

# Сохраняем предыдущий релиз (только для main)
if [ -n "$RELEASE_DIR" ]; then
  ssh -p "$PORT" -i ~/.ssh/id_ed25519 \
    -o UserKnownHostsFile=~/.ssh/known_hosts \
    "$USER@$HOST" "
    set -e
    mkdir -p '$REMOTE_BASE/releases'
    if [ -f '$REMOTE_BASE/index.html' ]; then
      mkdir -p '$RELEASE_DIR'
      cp -a '$REMOTE_BASE/.' '$RELEASE_DIR/' 2>/dev/null || true
      echo 'Saved release: $RELEASE_DIR'
    fi
  "
fi

# Всегда создаём целевой каталог (для main и preview)
ssh -p "$PORT" -i ~/.ssh/id_ed25519 \
  -o UserKnownHostsFile=~/.ssh/known_hosts \
  "$USER@$HOST" "mkdir -p '$TARGET'"

# Синхронизация
rsync -avz --delete \
  -e "ssh -p $PORT -i ~/.ssh/id_ed25519 -o UserKnownHostsFile=~/.ssh/known_hosts" \
  "$SRC" "$USER@$HOST:$TARGET/"

# Healthcheck
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