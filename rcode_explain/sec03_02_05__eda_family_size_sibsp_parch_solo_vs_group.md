# Explainer: `R/sec03_02_05__eda_family_size_sibsp_parch_solo_vs_group.R`

## Report section

Supports **§3.2.5** — **family structure** on board: siblings/spouses (**SibSp**), parents/children (**Parch**), derived **FamilySize**, and **IsSolo** (travelling alone or not).

## In plain English

Some passengers travelled alone; others in larger family groups. This script summarises the **numeric** variables that describe group size, prints **survival proportions by solo vs not solo**, and draws a **stacked bar** of survival share for each **FamilySize** value. That helps you see whether “big families” or “solo travellers” had different survival patterns **before** formal tests.

## Before you run

Cleaned CSV; **ggplot2** for the figure.

## What the script does (walkthrough)

Prints **`summary()`** for **SibSp**, **Parch**, **FamilySize**, and **IsSolo** in one go. Then **`prop.table(table(IsSolo, Survived), margin = 1)`** so you read “among solo travellers, what fraction survived?” For the plot, **FamilySize** is turned into a **factor** so each integer (1, 2, …) is its own bar category, with stacked survival proportions.

## What you will see in the console

Min/median/mean/max for the count variables, plus a **2-row** proportion table for **IsSolo** × **Survived**.

## Figures

- **`output/figures/fig__sec03_02_05__family_size_survival.png`**

## For your report / interpretation

Interpret carefully: **FamilySize** is from manifest fields, not a perfect “household” definition. Sparse counts for very large families can make small bars noisy. Point to **§4.2.4** for **chi-squared** tests (including **simulated p-value** for the full **FamilySize × Survived** table).
