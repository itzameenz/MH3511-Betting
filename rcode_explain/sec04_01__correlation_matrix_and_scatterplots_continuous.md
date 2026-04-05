# Explainer: `R/sec04_01__correlation_matrix_and_scatterplots_continuous.R`

## Report section

Supports **§4.1** — **linear associations** among numeric variables (Pearson correlation) and a **bivariate scatter** of **Age** vs **Fare** coloured by survival.

## In plain English

Correlation matrices summarise **how variables move together** on a −1 to 1 scale (linearly). Here the script picks a **subset of numeric columns** (age, fare, family counts, fare per person, party size, and **Survived** coded 0/1). Pearson correlation with **Survived** is **not** a substitute for logistic regression, but it hints at direction. The **scatterplot** shows the **joint** distribution of age and fare and whether survivors cluster in a region of the plane.

## Before you run

Cleaned CSV; **ggplot2** for scatter PNG.

## What the script does (walkthrough)

Builds a numeric data frame from intersecting column names, computes **`cor(..., use = "complete.obs")`** rounded to three decimals, prints the matrix. Then ggplot **points** with transparency for overplotting, **colour = Survived**.

## What you will see in the console

Full **correlation matrix** — copy into **Table 4.1** in **`REPORT_README.md`**.

## Figures

- **`output/figures/fig__sec04_01__scatter_age_fare_survival.png`**

## For your report / interpretation

Note that **correlation ≠ causation** and that **Pearson** measures **linear** association; skewed **Fare** can distort interpretation. Mention **Survived** as numeric correlation is a **rough** linear trend measure only. Cross-check stories with **Section 4.2** tests and **§4.3** logistic model.
