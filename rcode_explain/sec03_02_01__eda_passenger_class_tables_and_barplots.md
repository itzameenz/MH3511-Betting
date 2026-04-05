# Explainer: `R/sec03_02_01__eda_passenger_class_tables_and_barplots.R`

## Report section

Supports **§3.2.1** — exploratory view of **passenger class** (**Pclass**) and how it lines up with survival.

## In plain English

Class is a strong narrative variable (“first class vs steerage”). This script shows **how many people** are in each class, then **within each class** what **fraction** survived vs did not. The stacked bar chart makes that comparison visual without running a formal test yet (tests come in Section 4).

## Before you run

Cleaned data file present; **ggplot2** optional for the figure.

## What the script does (walkthrough)

Loads **`titanic_cleaned.csv`**. Prints a **frequency table** of **Pclass**, then a **two-way table** of **Pclass × Survived** converted to **row proportions** (so each class row sums to 1). That answers: “Among 1st-class passengers, what share survived?” The plot uses **geom_bar** with **position = "fill"** so the y-axis is **proportion** within class, which matches the printed row percentages.

## What you will see in the console

Class counts (how skewed the sample is toward 3rd class) and a **3 × 2** proportion table—ideal to paste or paraphrase in the EDA section.

## Figures

- **`output/figures/fig__sec03_02_01__passenger_class_distribution.png`** — stacked bars: survival share within each **Pclass**.

## For your report / interpretation

In words: higher classes tend to show **higher survival shares** in this dataset (your table will quantify that). Remind the reader this is **observational**; class correlates with sex, age, fare, and cabin. The formal **chi-squared** test for class × survival is in **`sec04_02_01`**.
