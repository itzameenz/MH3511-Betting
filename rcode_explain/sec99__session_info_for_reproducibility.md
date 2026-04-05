# Explainer: `R/sec99__session_info_for_reproducibility.R`

## Report section

Supports **Appendix** — **reproducibility** (R version, packages, locale).

## In plain English

Anyone reproducing your work needs to know **which R version** and **which package versions** you used. **`sessionInfo()`** prints that bundle: **R** under **platform**, **locale**, **attached** packages (e.g. **ggplot2**), and **loaded via namespace** dependencies. This script also prints the **resolved paths** to your **cleaned CSV** and **figures folder** so you notice if paths point somewhere unexpected.

## Before you run

Project root; **`bootstrap_paths.R`** must define **`DATA_CLEAN_CSV`** and **`OUTPUT_FIG_DIR`**.

## What the script does (walkthrough)

Sources bootstrap, **`cat`** the two path variables, then **`print(sessionInfo())`**.

## What you will see in the console

Two lines of paths, then a long **`sessionInfo()`** block—paste into **`REPORT_README.md`** where it says **`[Paste sessionInfo() output here]`**.

## Figures

None.

## For your report / interpretation

Standard appendix item. If a teammate gets **slightly different** numeric output, first compare **R** and **ggplot2** versions; second confirm they used the **same cleaned CSV**.
