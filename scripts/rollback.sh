#!/usr/bin/env bash
# Откат на предыдущий релиз.
set -euo pipefail

HOST="${HELIOS_HOST:?}"
USER="${HELIOS_USER:?}"
REMOTE_BASE="${HELIOS_PATH:?}"

echo ">>> Доступные релизы:"
ssh "$USER@$HOST" "ls -1t '$REMOTE_BASE/releases' | head -20"

read -rp "Введите имя релиза для отката: " RELEASE
ssh "$USER@$HOST" "
  set -e
  test -d '$REMOTE_BASE/releases/$RELEASE'
  rm -rf '$REMOTE_BASE/current'
  cp -a '$REMOTE_BASE/releases/$RELEASE' '$REMOTE_BASE/current'
  echo 'Rolled back to $RELEASE'
"