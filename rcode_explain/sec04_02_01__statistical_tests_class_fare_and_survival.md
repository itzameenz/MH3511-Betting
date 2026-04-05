# Explainer: `R/sec04_02_01__statistical_tests_class_fare_and_survival.R`

## Report section

Supports **§4.2.1** — formal links between **class**, **fare**, and **survival**.

## In plain English

**Passenger class** is categorical and **survival** is binary, so a **chi-squared test of independence** on the **Pclass × Survived** table asks whether the distribution of survival **differs across classes** (roughly: “is survival independent of class?”). **Fare** is continuous and **skewed**, and we do not assume normality, so the script uses a **Wilcoxon rank-sum test** comparing **Fare** between survivors and non-survivors (a **nonparametric** two-group comparison). The **boxplot** uses a **log10** y-scale to handle skewness; **zero fares** are shifted slightly upward **for plotting only** so **log10** is defined—the **Wilcoxon** still uses **raw Fare**.

## Before you run

Cleaned CSV; **ggplot2** for the fare figure.

## What the script does (walkthrough)

Runs **`chisq.test(table(Pclass, Survived))`**, then **`wilcox.test(Fare ~ Survived)`**. Builds **`Fare_log = pmax(Fare, epsilon)`** with **epsilon** = one-tenth of the smallest **positive** fare, then ggplot boxplots of **Fare_log** by **Pclass**, **faceted** by **Survived**, with **`scale_y_log10()`**.

## What you will see in the console

Chi-squared statistic, df, **p-value**; Wilcoxon **W** and **p-value**. Paste both into **§4.2** with **hypotheses** stated in words.

## Figures

- **`output/figures/fig__sec04_02_01__fare_by_class_survival.png`**

## For your report / interpretation

State **null**: independence (chi-squared); **null** for Wilcoxon: equal distribution of fare across survival groups (location shift framing in R output). If **p** is tiny, conclude **strong evidence** of association in this sample. Acknowledge **fare** and **class** overlap conceptually; **§4.3** adjusts them together. Mention the **zero-fare** display trick in one footnote if you show the log plot.
