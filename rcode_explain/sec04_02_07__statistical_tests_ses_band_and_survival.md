# Explainer: `R/sec04_02_07__statistical_tests_ses_band_and_survival.R`

## Report section

**§4.2.7** — **χ²** test of **SES_band × Survived**.

## In plain English

Tests whether survival differs across the three **SES_band** categories. **SES_band** was **built from** the same ticket data, so a significant result is **not** independent evidence of a new “income” mechanism—it mainly summarises a **fare gradient** that already relates to survival.

## Before you run

Cleaned CSV; **ggplot2** for the bar chart.

## What the script does

`chisq.test(table(SES_band, Survived))`, print table, save **`fig__sec04_02_07__ses_band_survival_counts.png`**.

## Write-up

Report χ² statistic, df, *p*-value; note **overlap** with §4.2.1 and §4.3 (**Fare** / **Pclass**).
