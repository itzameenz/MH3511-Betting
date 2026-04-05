# MH3511 — Titanic survival (group project)

R-based analysis for **MH3511 Data Analysis with Computer**: cleaning, EDA, hypothesis tests, logistic regression, and a simple train/test predictive check.

## Folder map

| Path | Role |
|------|------|
| **`data_cleaning/`** | **`clean_and_save_titanic.R`** + **`README.md`** — only code that reads **raw** CSV |
| **`data/`** | Put **`Titanic-Dataset.csv`** here; cleaning writes **`titanic_cleaned.csv`** |
| **`R/`** | Analysis scripts (**§3.1–§4.4**, appendix) — read cleaned data only |
| **`R/bootstrap_paths.R`** | Shared paths + `load_titanic_clean()` — sourced by every `R/sec*.R` |
| **`rcode_explain/`** | Short **.md** per script — read this if R is confusing |
| **`output/figures/`** | Saved **PNG** figures from ggplot |
| **`REPORT_README.md`** | Long **report manuscript draft** + figure callouts (for Word) |

## Dependencies

- **R** (any recent version).
- **ggplot2** for figures (`install.packages("ggplot2")`). Scripts skip plots if ggplot2 is missing but still print tables/tests.

## How to run (working directory = this folder)

```r
setwd("path/to/MH3511")   # Windows example: "~/OneDrive/Desktop/MH3511"

source("data_cleaning/clean_and_save_titanic.R")

source("R/sec03_01__eda_main_outcome_survival_barplot_and_rates.R")
# … run other R/sec*.R as needed (see rcode_explain/INDEX.md)

# Or run everything (clean + all sec*.R in order):
source("R/run_all_analysis.R")
```

Run **`data_cleaning/clean_and_save_titanic.R` once** before any file under **`R/`**.

A full run writes PNGs under **`output/figures/`** and can log console output to **`output/analysis_console_log.txt`** (see **`REPORT_README.md`**). From the project root, after cleaning:

```sh
Rscript tests/test_stratified_split.R
Rscript tests/test_ses_band.R
```

## Documentation

- **Cleaning rules + narrative explanation (report §3):** [`data_cleaning/README.md`](data_cleaning/README.md) — includes **What the cleaning does (in plain language)** for the report text
- **Per-script explainers:** [`rcode_explain/INDEX.md`](rcode_explain/INDEX.md)
- **Full report draft:** [`REPORT_README.md`](REPORT_README.md)

## Data

If `data/Titanic-Dataset.csv` is missing, copy your Kaggle-style Titanic training CSV into **`data/`** with that exact name (see [`data/README.txt`](data/README.txt)).

## Course integrity

Follow your instructor’s rules on collaboration and GenAI disclosure on the title page.
