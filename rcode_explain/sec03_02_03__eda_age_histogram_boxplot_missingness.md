# Explainer: `R/sec03_02_03__eda_age_histogram_boxplot_missingness.R`

## Report section

Supports **§3.2.3** — **Age** distribution and how it differs between survivors and non-survivors (after cleaning, age should be complete).

## In plain English

Age is continuous and often skewed. Histograms **split by survival** show whether survivors tended to be younger (e.g. children) or whether distributions overlap a lot. A **boxplot** by survival gives a quick median and IQR comparison. The script also prints **`summary(Age)`** and counts **NAs**; after cleaning you expect **zero** missing ages, which is a nice sanity check to mention.

## Before you run

Cleaned CSV; **ggplot2** for both PNGs.

## What the script does (walkthrough)

Loads data, prints **summary** statistics for **Age** and the count of missing values. Builds two plots: (1) **histogram of Age** with **facets** by **Survived**, (2) **boxplot of Age** with **Survived** on the x-axis.

## What you will see in the console

Min, quartiles, mean, max for age, plus **`NA count Age:`** — should be **0** if cleaning ran.

## Figures

- **`output/figures/fig__sec03_02_03__age_histogram_by_survival.png`**
- **`output/figures/fig__sec03_02_03__age_boxplot_by_survival.png`**

## For your report / interpretation

Describe shape (skew, range) and compare **centres** and spread between groups **verbally**. Note that ages were **imputed** for missing values in cleaning, so extreme smoothing in the middle of a stratum is possible—brief honesty is good. The **Wilcoxon** rank-sum test for age vs survival is in **`sec04_02_03`**.
