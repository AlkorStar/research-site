#!/usr/bin/env bash
# Откат на предыдущий релиз.
set -euo pipefail

HOST="${HELIOS_HOST:?HELIOS_HOST not set}"
PORT="${HELIOS_PORT:-22}"
USER="${HELIOS_USER:?HELIOS_USER not set}"
REMOTE_BASE="${HELIOS_PATH:?HELIOS_PATH not set}"

echo ">>> Доступные релизы на $HOST:$REMOTE_BASE/releases:"
ssh -p "$PORT" "$USER@$HOST" "ls -1t '$REMOTE_BASE/releases' 2>/dev/null | head -20"

read -rp "Введите имя релиза для отката: " RELEASE

if [ -z "$RELEASE" ]; then
  echo "!!! Релиз не указан"
  exit 1
fi

echo ">>> Проверяем, что релиз существует..."
ssh -p "$PORT" "$USER@$HOST" "test -d '$REMOTE_BASE/releases/$RELEASE' || (echo '!!! Нет такого релиза'; exit 1)"

echo ">>> Сохраняем текущее состояние в current-backup..."
ssh -p "$PORT" "$USER@$HOST" "
  set -e
  rm -rf '$REMOTE_BASE/current-backup'
  mkdir -p '$REMOTE_BASE/current-backup'
  cp -a '$REMOTE_BASE/.' '$REMOTE_BASE/current-backup/' 2>/dev/null || true
"

echo ">>> Удаляем текущие файлы сайта..."
ssh -p "$PORT" "$USER@$HOST" "
  set -e
  cd '$REMOTE_BASE'
  rm -rf _static _images _sources _sphinx_design_static
  rm -f *.html *.js *.inv
"

echo ">>> Копируем релиз $RELEASE в корень..."
ssh -p "$PORT" "$USER@$HOST" "
  set -e
  cp -a '$REMOTE_BASE/releases/$RELEASE/.' '$REMOTE_BASE/'
"

echo ">>> Откат выполнен. Текущий сайт соответствует релизу $RELEASE"
echo ">>> Откат можно отменить: current-backup лежит в $REMOTE_BASE/current-backup/"