# Explainer: `R/sec03_01__eda_main_outcome_survival_barplot_and_rates.R`

## Report section

Supports **§3.1** — summary of the **main outcome**, **Survived** (died vs survived).

## In plain English

Before looking at predictors, you need to know the **base rate**: in this sample, how many people died versus survived? This script prints those **counts or proportions** and, if **ggplot2** is installed, saves a **bar chart** you can drop straight into the report as **Figure 3.1**.

## Before you run

Project root as working directory; **`data/titanic_cleaned.csv`** must exist (run the cleaning script first). Install **ggplot2** if you want the PNG.

## What the script does (walkthrough)

It sources **`R/bootstrap_paths.R`**, which defines where the cleaned CSV lives and provides **`load_titanic_clean()`**. It loads the data and prints **overall survival proportions** (the share with **Survived = 0** and **Survived = 1**). Then it builds a **ggplot** bar chart of counts by survival status and saves it under **`output/figures/`**.

## What you will see in the console

Two numbers that sum to 1 (or proportional breakdown)—your **empirical survival rate** in this training-style sample. Use these in the text when you describe imbalance (more deaths than survivors in this file).

## Figures

- **`output/figures/fig__sec03_01__survival_overall.png`** — bar heights = number of passengers in each survival category.

## For your report / interpretation

Describe the outcome as **binary** and report the **marginal proportions**. This is descriptive only (no test here). A sentence like “In our analytic sample, about **38%** survived and **62%** did not” (use your exact printed values) sets up later chi-squared and regression results.
