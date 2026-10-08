#!/usr/bin/env bash
# Откат на предыдущий релиз.
set -euo pipefail

HOST="${HELIOS_HOST:?HELIOS_HOST not set}"
PORT="${HELIOS_PORT:-22}"
USER="${HELIOS_USER:?HELIOS_USER not set}"
REMOTE_BASE="${HELIOS_PATH:?HELIOS_PATH not set}"
SSH_KEY="${HELIOS_SSH_KEY_PATH:-$HOME/.ssh/helios_deploy}"

SSH_OPTS=(-p "$PORT" -i "$SSH_KEY" -o UserKnownHostsFile="$HOME/.ssh/known_hosts")

echo ">>> Доступные релизы на $HOST:$REMOTE_BASE/releases:"
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "ls -1t '$REMOTE_BASE/releases' 2>/dev/null | head -20"

read -rp "Введите имя релиза для отката: " RELEASE

if [ -z "$RELEASE" ]; then
  echo "!!! Релиз не указан"
  exit 1
fi

echo ">>> Проверяем, что релиз существует..."
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "test -d '$REMOTE_BASE/releases/$RELEASE' || (echo '!!! Нет такого релиза'; exit 1)"

echo ">>> Сохраняем текущее состояние в current-backup..."
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "
  set -e
  rm -rf '$REMOTE_BASE/current-backup'
  mkdir -p '$REMOTE_BASE/current-backup'
  cp -a '$REMOTE_BASE/.' '$REMOTE_BASE/current-backup/' 2>/dev/null || true
"

echo ">>> Удаляем текущие файлы сайта..."
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "
  set -e
  cd '$REMOTE_BASE'
  rm -rf _static _images _sources _sphinx_design_static
  rm -f *.html *.js *.inv
"

echo ">>> Копируем релиз $RELEASE в корень..."
ssh "${SSH_OPTS[@]}" "$USER@$HOST" "
  set -e
  cp -a '$REMOTE_BASE/releases/$RELEASE/.' '$REMOTE_BASE/'
"

echo ">>> Откат выполнен. Текущий сайт соответствует релизу $RELEASE"
echo ">>> Откат можно отменить: current-backup лежит в $REMOTE_BASE/current-backup/"