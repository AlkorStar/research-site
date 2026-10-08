"""Конфигурация Sphinx для сайта результатов исследования."""
from __future__ import annotations

import os
import subprocess
from datetime import datetime

project = "Результаты исследования"
author = "Екатерина Алкор"
copyright = f"{datetime.now().year}, {author}"

# Базовый URL. Для Helios — вида https://helios.example.ru/~user/research-site/
site_url = os.environ.get("SITE_URL", "http://localhost:8000/")


def get_git_commit() -> str:
    """Возвращает короткий хеш коммита или 'unknown'."""
    try:
        return subprocess.check_output(
            ["git", "rev-parse", "--short", "HEAD"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except Exception:
        return "unknown"


build_date = datetime.now().strftime("%Y-%m-%d %H:%M")
git_commit = get_git_commit()
data_version = os.environ.get("DATA_VERSION", "v1.0")

extensions = [
    "myst_parser",
    "sphinxcontrib.bibtex",
    "sphinx_design",
    "sphinx_copybutton",
    "sphinx_togglebutton",
    "sphinxcontrib.mermaid",
    "sphinxext.opengraph",
]

myst_enable_extensions = [
    "amsmath",
    "colon_fence",
    "deflist",
    "dollarmath",
    "fieldlist",
    "html_admonition",
    "html_image",
    "linkify",
    "replacements",
    "smartquotes",
    "strikethrough",
    "substitution",
    "tasklist",
]
myst_heading_anchors = 3
myst_substitutions = {
    "git_commit": git_commit,
    "build_date": build_date,
    "data_version": data_version,
}

bibtex_bibfiles = ["references.bib"]
bibtex_default_style = "plain"
bibtex_reference_style = "author_year"

html_theme = "sphinx_book_theme"
html_title = project
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_logo = "_static/logo.png"
html_favicon = "_static/logo.png"

html_theme_options = {
    "repository_url": "https://github.com/username/research-site",
    "use_repository_button": True,
    "use_issues_button": True,
    "use_download_button": True,
    "show_toc_level": 2,
    "navigation_with_keys": True,
}

ogp_site_url = site_url
ogp_image = site_url + "_static/logo.png"

language = "ru"
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_context = {
    "git_commit": git_commit,
    "build_date": build_date,
    "data_version": data_version,
}

# Нумерация рисунков, таблиц, листингов
numfig = True
numfig_format = {
    "figure": "Рис. %s",
    "table": "Табл. %s",
    "code-block": "Листинг %s",
    "section": "Раздел %s",
}
numfig_secnum_depth = 1