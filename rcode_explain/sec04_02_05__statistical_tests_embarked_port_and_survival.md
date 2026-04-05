# Explainer: `R/sec04_02_05__statistical_tests_embarked_port_and_survival.R`

## Report section

Supports **§4.2.5** — **Embarked** vs survival.

## In plain English

This is a **chi-squared test of independence** on **Embarked × Survived** with three port categories. A significant result means survival **proportions differ** across ports **in this table**—not that boarding location **caused** survival. **Confounding** by class (and fare) is the standard critique; your write-up should mention that **embarkation** is partly a proxy for **who** boarded there.

## Before you run

Cleaned CSV; **ggplot2** for figure.

## What the script does (walkthrough)

**`chisq.test(table(Embarked, Survived))`**. ggplot **dodged** **geom_bar** of **counts** (not proportions)—complements the **§3.2.6** filled bar.

## What you will see in the console

Chi-squared statistic, **df = 2**, **p-value**.

## Figures

- **`output/figures/fig__sec04_02_05__embarked_counts.png`**

## For your report / interpretation

Report test, then spend at least one sentence on **interpretation limits**. Optionally note that **§4.3** includes **Embarked** in the logistic model **adjusting** for other variables—compare narrative to **§4.2.5** bivariate result.
