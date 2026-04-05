# Explainer: `R/sec03_02_04__eda_fare_histogram_fare_per_person_boxplots.R`

## Report section

Supports **§3.2.4** — **Fare** paid and **fare per person** when tickets are shared.

## In plain English

**Fare** in the raw data is the **total** for that row’s ticket in many cases; several passengers can share one ticket string. The cleaned column **`Fare_per_person`** divides total fare by **`Ticket_party_size`**, so you can compare “what each seat effectively cost” a bit more fairly. This script summarises both numerically and shows **right-skew** (typical for money variables) in a histogram, and compares **Fare_per_person** across survival with a boxplot.

## Before you run

Cleaned CSV; **ggplot2** for figures.

## What the script does (walkthrough)

Prints **`summary(Fare)`** and **`summary(Fare_per_person)`**. Builds a **histogram** of raw **Fare**, then a **boxplot** of **Fare_per_person** by **Survived** (with slightly transparent outliers).

## What you will see in the console

Five-number summaries plus mean for both variables—useful for saying “fare is highly skewed with a long right tail” with numbers.

## Figures

- **`output/figures/fig__sec03_02_04__fare_histogram.png`**
- **`output/figures/fig__sec03_02_04__fare_per_person_boxplot.png`**

## For your report / interpretation

Link **fare** and **class** in words (first class paid more). Explain **why** **Fare_per_person** exists in one sentence. Formal comparison of **Fare** by survival (**Wilcoxon**) is in **`sec04_02_01`**; plots in **`sec04_02_01`** use a **log scale** with a small adjustment for zero fares—see that explainer if the marker asks.
