# Explainer: `R/sec04_02_02__statistical_tests_sex_and_survivor_composition.R`

## Report section

Supports **§4.2.2** — **Sex** vs survival, and **composition** among survivors (what fraction male).

## In plain English

First, a **chi-squared** test (with **Yates’ continuity correction** by default in R for 2×2 tables) assesses whether **sex** and **survival** are associated. Second, among **only those who survived**, the script computes the **proportion male** and runs an **exact binomial test** against the null that the proportion is **0.5**—a focused question: “Among survivors, are males **half** the group or not?” (You expect **no**, because females survived at higher rates.)

## Before you run

Cleaned CSV; **ggplot2** for dodged bar chart.

## What the script does (walkthrough)

**`chisq.test(table(Sex, Survived))`**. Subsets survivors, computes **mean(Sex == "male")**, prints it, then **`binom.test`** with **x** = number of male survivors and **n** = total survivors.

## What you will see in the console

Chi-squared output; one line with **proportion male**; binomial **p-value** and **95% CI** for the proportion—excellent to report verbatim.

## Figures

- **`output/figures/fig__sec04_02_02__sex_survival_counts.png`** — **counts** (dodged), not proportions.

## For your report / interpretation

Separate the two ideas: (1) **association** in the whole table, (2) **descriptive inference** about **survivor composition**. Explain **binom.test** in plain language: “testing whether the survivor group is split 50–50 male/female.” Connect to the historical **WCF** narrative without over-claiming.
