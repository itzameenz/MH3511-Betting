# Explainer: `R/sec03_02_02__eda_sex_tables_and_barplots.R`

## Report section

Supports **§3.2.2** — **Sex** and survival (the famous “women and children first” angle in descriptive form).

## In plain English

The script tabulates **male vs female** counts, then shows **survival rates within each sex** using row proportions. The figure is another **100% stacked** bar: easy to see that **females** have a much higher survival share than **males** in this sample.

## Before you run

Cleaned CSV; **ggplot2** for PNG.

## What the script does (walkthrough)

Same pattern as the class EDA: **`table(Sex)`**, then **`prop.table(..., margin = 1)`** on **Sex × Survived**. The ggplot uses **Sex** on the x-axis and **fill = Survived** with stacked bars.

## What you will see in the console

Counts by sex (there are more males in the manifest) and **row-wise** survival proportions—strong material for one paragraph of EDA.

## Figures

- **`output/figures/fig__sec03_02_02__sex_survival_share.png`**

## For your report / interpretation

Emphasize that the **association is very strong** descriptively; the formal **chi-squared** test appears in **`sec04_02_02`**. You can mention **“women and children first”** as historical context, but keep statistics phrased as **association**, not proof of policy on the ship.
