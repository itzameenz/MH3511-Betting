# Explainer: `R/sec03_02_07__eda_ticket_cabin_derived_title_deck_party_size.R`

## Report section

Supports **§3.2.7** — **derived** text fields and groups: **Title** from name, **Deck** from cabin, **Ticket_party_size**.

## In plain English

This script is a **mixed bag EDA**: it prints the **most common titles** (Mr, Mrs, Miss, …), a frequency table of **Deck** (many **U** = unknown cabin), and a summary of **Ticket_party_size**. The figure collapses rare titles into **Other** and shows **survival share** for the **top eight** titles plus **Other**, so the plot stays readable.

## Before you run

Cleaned CSV; **ggplot2** for PNG.

## What the script does (walkthrough)

Sorts title counts descending and prints the **head** (top 15). Prints **`table(Deck)`**—expect **U** to be large. Prints **`summary(Ticket_party_size)`**—most tickets are size 1, some are larger groups. For ggplot, keeps the **eight** most frequent titles and relabels the rest as **“Other”**, rotates x-labels for readability, stacked bars by survival.

## What you will see in the console

Title frequencies, deck counts, party-size summary—good for describing **data richness** and **missing cabin** in words.

## Figures

- **`output/figures/fig__sec03_02_07__title_survival.png`**

## For your report / interpretation

**Title** is a coarse social label; **Deck** is only as good as **Cabin** (mostly missing). **Ticket_party_size** supports the **same-ticket** analysis in **`sec04_02_06`**. Keep interpretation descriptive here; multivariable models in **`sec04_03`** can include some of these ideas indirectly (e.g. class and sex absorb part of “title”).
