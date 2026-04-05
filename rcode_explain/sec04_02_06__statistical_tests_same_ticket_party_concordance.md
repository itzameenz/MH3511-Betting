# Explainer: `R/sec04_02_06__statistical_tests_same_ticket_party_concordance.R`

## Report section

Supports **§4.2.6** — passengers on the **same ticket** (travel party proxy) and **concordance** of survival.

## In plain English

The script restricts to passengers whose **ticket appears more than once** in the data. For each such person, it asks whether **any other** passenger on that ticket **survived**. That builds a **2×2** table: **this passenger died/lived** × **someone else on ticket survived yes/no**. **Fisher’s exact test** is appropriate for small or imbalanced tables and yields an **odds ratio** for association. Separately, it classifies each **multi-passenger ticket** as **all survived**, **all died**, or **mixed**, and tabulates how many tickets fall in each pattern—then plots that mix.

## Before you run

Cleaned CSV; **ggplot2** for party-mix bar chart.

## What the script does (walkthrough)

Computes party size per ticket, filters **`n_on_ticket > 1`**, loops to flag **`other_survived`**, builds **`table(Self, Other)`**, runs **`fisher.test`** if the table is proper 2×2. Aggregates **`party_pattern`** per ticket string, **`table`**, ggplot **col** chart.

## What you will see in the console

The **2×2** counts, Fisher **p-value**, **OR** and CI; then counts of **all_died / all_survived / mixed** parties.

## Figures

- **`output/figures/fig__sec04_02_06__ticket_party_mix.png`**

## For your report / interpretation

Stress that **ticket ≠ family**, though it often proxies joint booking. **Mixed** parties show disagreement within the group. Avoid causal language (“staying together” is a **story**, statistics show **association**). If Fisher is skipped (degenerate table), the script messages—unlikely on full Titanic training data.
