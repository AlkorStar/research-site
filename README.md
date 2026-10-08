# Research Site

Статический сайт для публикации результатов исследования.
Построен на Sphinx + MyST-Parser + sphinx-book-theme.

Публикует результаты заданий T1 (сравнение SSG) и P4 (деплой на Helios).

## Быстрый старт

```bash
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt
make check      # строгая сборка
make serve      # http://localhost:8000
```

## Структура

- `data/` — исходные данные
- `scripts/` — генерация графиков, деплой, откат
- `docs/` — исходники сайта (MyST Markdown)
- `.github/workflows/` — CI/CD

## Деплой на Helios

Секреты в GitHub Actions:

| Секрет | Значение |
|---|---|
| `HELIOS_SSH_KEY` | приватный deploy-ключ |
| `HELIOS_HOST` | хост Helios |
| `HELIOS_USER` | логин |
| `HELIOS_PATH` | путь к каталогу сайта |
| `HELIOS_URL` | публичный URL |
| `SITE_URL` | то же, что HELIOS_URL |

## Лицензии

- Код — MIT (см. `LICENSE-CODE`)
- Контент — CC BY 4.0 (см. `LICENSE-CONTENT`)