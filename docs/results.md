# Результаты

## Данные

Исходные данные: `data/experiment.csv` (21 точка).

```{admonition} Версия данных
:class: build-meta

Хеш данных: `{{ data_version }}` (см. `metrics.json`)
```

## Таблица метрик

```{list-table} Сводные метрики
:header-rows: 1
:name: tbl:metrics

* - Метрика
  - Значение
* - RMSE
  - 0.08
* - $R^2$
  - 0.999
* - $\beta_0$
  - 1.05
* - $\beta_1$
  - 0.84
```

Ссылка на таблицу {numref}`tbl:metrics`.

## График

```{figure} _static/plot.png
:name: fig:plot
:width: 85%

Зависимость $y$ от $x$ и подобранная модель.
```

См. {numref}`fig:plot`.

## Цитирование

Методика основана на {cite:p}`smith2020experiment`.