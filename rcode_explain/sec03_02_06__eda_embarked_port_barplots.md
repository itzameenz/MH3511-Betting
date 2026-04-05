# Explainer: `R/sec03_02_06__eda_embarked_port_barplots.R`

## Report section

Supports **§3.2.6** — **Embarked** (Cherbourg, Queenstown, Southampton) and survival, as **exploratory** plots and tables.

## In plain English

Port of embarkation might relate to survival, but it is also **confounded** with class and fare (different ports had different passenger mixes). This script simply shows **how many** people embarked at each code and **within each port** the **fraction** who survived. It does **not** claim causation—just describes the pattern you see in the data.

## Before you run

Cleaned CSV; **ggplot2** for PNG.

## What the script does (walkthrough)

**`table(Embarked)`** for counts, then **row proportions** of **Embarked × Survived**. The plot is a **100% stacked bar** by port (same logic as class and sex EDA).

## What you will see in the console

Roughly: Southampton dominates sample size; row proportions show survival share **C**, **Q**, **S**—useful for one careful paragraph.

## Figures

- **`output/figures/fig__sec03_02_06__embarked_survival.png`**

## For your report / interpretation

Explicitly mention **confounding**: e.g. Cherbourg had more first-class passengers, so a higher survival share there does not mean “boarding at Cherbourg caused survival.” The **chi-squared** test for **Embarked × Survived** is in **`sec04_02_05`**; the **§4.2** figure there uses **dodged counts** instead of proportions—complementary views.
