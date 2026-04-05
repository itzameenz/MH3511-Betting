# Explainer: `R/sec03_02_08__eda_ses_band_survival.R`

## Report section

**§3.2.8** — exploratory view of **SES_band** vs survival, **faceted by Pclass**.

## In plain English

**SES_band** is a **rule-based** label: within each ticket class, who paid a **lower vs higher share** of the ticket (**Fare_per_person**), in three groups. The plot shows whether survival shares line up with that ordering **within** each class.

## Before you run

Cleaned CSV; **ggplot2** optional for the PNG.

## What the script does

Prints **Pclass × SES_band** counts and row-wise proportions of **Survived** within **SES_band**. Saves **`output/figures/fig__sec03_02_08__ses_band_survival_by_class.png`**.

## Write-up caveat

Call it a **proxy** or **within-class fare band**, never “income.” Expect overlap with **Pclass** and **Fare** in interpretation.
