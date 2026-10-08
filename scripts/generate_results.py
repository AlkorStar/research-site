"""Генерация графиков, таблиц и метаданных для сайта.

Читает data/experiment.csv, считает линейную регрессию,
строит график и сохраняет метрики в JSON.

Дополнительно строит столбчатую диаграмму итоговых баллов T1
(сравнение SSG) для страницы t1_matrix.md.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data" / "experiment.csv"
OUT = ROOT / "docs" / "_static"
OUT.mkdir(parents=True, exist_ok=True)


def data_hash(path: Path) -> str:
    """Короткий SHA-256 хеш файла данных."""
    return hashlib.sha256(path.read_bytes()).hexdigest()[:12]


def fit_regression(df: pd.DataFrame) -> dict:
    """Линейная регрессия y = beta0 + beta1 * x."""
    x = df["x"].to_numpy()
    y = df["y"].to_numpy()
    beta1, beta0 = np.polyfit(x, y, 1)
    y_pred = beta0 + beta1 * x
    rmse = float(np.sqrt(np.mean((y - y_pred) ** 2)))
    r2 = float(1 - np.sum((y - y_pred) ** 2) / np.sum((y - y.mean()) ** 2))
    return {
        "beta0": float(beta0),
        "beta1": float(beta1),
        "rmse": rmse,
        "r2": r2,
        "n": int(len(df)),
    }


def plot_regression(df: pd.DataFrame, metrics: dict) -> None:
    """Сохраняет график регрессии."""
    x = df["x"].to_numpy()
    y = df["y"].to_numpy()
    y_pred = metrics["beta0"] + metrics["beta1"] * x

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.scatter(x, y, alpha=0.6, label="Данные")
    ax.plot(
        x,
        y_pred,
        color="crimson",
        linewidth=2,
        label=f"$y = {metrics['beta0']:.2f} + {metrics['beta1']:.2f}x$",
    )
    ax.set_xlabel("$x$")
    ax.set_ylabel("$y$")
    ax.set_title("Линейная регрессия: данные и модель")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT / "plot.png", dpi=150)
    plt.close(fig)


def plot_t1_scores() -> None:
    """Столбчатая диаграмма итоговых баллов T1."""
    generators = ["MkDocs", "Sphinx", "Jupyter Book 2", "Pelican"]
    scores = [2.57, 4.84, 3.84, 1.24]
    colors = ["#4c72b0", "#55a868", "#c44e52", "#8172b2"]

    fig, ax = plt.subplots(figsize=(8, 4.5))
    bars = ax.bar(generators, scores, color=colors)
    for bar, score in zip(bars, scores):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 0.08,
            f"{score:.2f}",
            ha="center",
            va="bottom",
            fontsize=10,
        )
    ax.set_ylabel("Итоговый балл")
    ax.set_title("T1: сравнение генераторов статических сайтов")
    ax.set_ylim(0, 5.5)
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT / "t1_chart.png", dpi=150)
    plt.close(fig)


def main() -> None:
    if not DATA.exists():
        raise SystemExit(f"Нет файла данных: {DATA}")

    df = pd.read_csv(DATA)
    metrics = fit_regression(df)
    metrics["data_hash"] = data_hash(DATA)

    plot_regression(df, metrics)
    plot_t1_scores()

    (OUT / "metrics.json").write_text(
        json.dumps(metrics, indent=2, ensure_ascii=False)
    )
    print(json.dumps(metrics, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()