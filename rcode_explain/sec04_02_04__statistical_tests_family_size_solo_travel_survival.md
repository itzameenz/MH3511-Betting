# Explainer: `R/sec04_02_04__statistical_tests_family_size_solo_travel_survival.R`

## Report section

Supports **§4.2.4** — **Family size** and **solo travel** vs survival.

## In plain English

**FamilySize** (integer 1, 2, …) crossed with survival produces a table with **many cells** and some **small expected counts** under independence, so a standard chi-squared **p-value** can be unreliable. This script still uses Pearson’s chi-squared statistic but obtains a **p-value by Monte Carlo simulation** (**`simulate.p.value = TRUE`**, **B = 10000`**), which avoids the “chi-squared approximation may be incorrect” warning while keeping the same contingency table. For **IsSolo** (binary), a **2×2** table uses the usual chi-squared with **Yates’ correction**.

## Before you run

Cleaned CSV; **ggplot2** for solo bar figure.

## What the script does (walkthrough)

Factor **FamilySize**, build **table × Survived**, **`chisq.test(..., simulate.p.value = TRUE)`**. Then **`chisq.test(table(IsSolo, Survived))`**. Plot: **stacked** survival share for **Not solo** vs **Solo** (labels 0/1 mapped to words).

## What you will see in the console

Simulated **p-value** for family size (report **B** replicates in methods if required); standard output for **IsSolo** test.

## Figures

- **`output/figures/fig__sec04_02_04__solo_survival.png`**

## For your report / interpretation

Explain **why** simulation was used (sparse large family sizes). **IsSolo** is easier to narrate than eleven family-size categories. Tie back to **§3.2.5** EDA plots.
