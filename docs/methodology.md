# Методика

## Модель

Рассмотрим линейную регрессию:

```{math}
:label: eq:regression

y = \beta_0 + \beta_1 x + \varepsilon
```

Ссылка на уравнение {eq}`eq:regression`.

## Оценки коэффициентов

```{math}
:label: eq:system

\begin{align}
\hat{\beta}_1 &= \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sum (x_i - \bar{x})^2} \\
\hat{\beta}_0 &= \bar{y} - \hat{\beta}_1 \bar{x}
\end{align}
```

См. {eq}`eq:system`.

## Метрики качества

- RMSE — корень из среднего квадрата ошибки.
- $R^2$ — коэффициент детерминации.

Как показано в {cite:p}`smith2020experiment`, эти метрики достаточны
для базового сравнения моделей.