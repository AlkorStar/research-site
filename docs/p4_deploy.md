# P4. Развёртывание на Helios с контролем качества доставки

## Цель

Автоматизировать выкладку сайта на Helios ИТМО по SSH/rsync с отдельным
deploy-ключом, добавить healthcheck, preview-сборки и откат.

## Архитектура

```{mermaid}
flowchart LR
    A[git push] --> B[CI: build]
    B --> C{Ветка main?}
    C -- да --> D[rsync → current/]
    C -- нет --> E[rsync → preview/branch/]
    D --> F[healthcheck]
    E --> F
    F -- ok --> G[Готово]
    F -- fail --> H[Job failed]
```

## Ключевые решения

### Отдельный deploy-ключ

- Генерируется `ssh-keygen -t ed25519`.
- Публичный ключ кладётся в `~/.ssh/authorized_keys` на сервере.
- Ключ **ограничен командой rsync** через `command="..."` в `authorized_keys`.
- Приватный ключ хранится только в секретах CI.

### known_hosts без отключения проверки

```bash
ssh-keyscan -H $HELIOS_HOST >> ~/.ssh/known_hosts
```

`StrictHostKeyChecking=no` **не используется** — это открыло бы MITM-атаку.

### Healthcheck

После деплоя CI запрашивает опубликованный URL и проверяет:
- код ответа 200;
- наличие контрольной строки в HTML.

При несовпадении job завершается с ошибкой.

### Preview-сборки

- `main` → `~/research-site/current/`
- `feature/foo` → `~/research-site/preview/feature-foo/`

### Откат

Перед каждым деплоем в `main` предыдущий `current/` копируется
в `releases/<timestamp>/`. Откат — копирование нужного релиза обратно в `current/`.

## Результаты измерений

```{list-table} Сравнение GitHub Pages и Helios
:header-rows: 1
:name: tbl:deploy-compare

* - Параметр
  - GitHub Pages
  - Helios
* - Время доставки
  - 30–60 с
  - 5–15 с
* - Надёжность
  - Высокая (CDN)
  - Зависит от сервера
* - Отладка
  - Логи в Actions
  - SSH + логи nginx
* - Preview
  - Через отдельные репозитории
  - Через подкаталоги
* - Откат
  - Через артефакты
  - Через releases/
```

## Поведение при обрыве деплоя

Если rsync прервался:
- `current/` может оказаться в промежуточном состоянии;
- healthcheck упадёт;
- job завершится с ошибкой;
- предыдущий релиз остаётся в `releases/`, откат возможен.

Рекомендация: деплоить в `current.new/`, затем `mv current.new current`
(атомарная замена). В текущей реализации это не сделано — зафиксировано
как ограничение.