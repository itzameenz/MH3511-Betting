# Billionaires Analysis Repo

This repo now uses the provided billionaire dataset as the only source data.

## Files

- `data/raw/Billionaires Statistics Dataset.csv`: original dataset copied from Downloads
- `scripts/process_billionaires_data.R`: analysis pipeline
- `data/processed/billionaires_analysis_ready.csv`: cleaned dataset with derived analysis columns
- `output/histograms/raw/`: histograms for numeric analysis columns
- `output/histograms/transformed/`: histograms for skew-reduced transformed columns
- `output/skew_summary.csv`: raw skewness, chosen transform, and transformed skewness
- `output/correlation_to_net_worth.csv`: correlations against `net_worth`

## Run

```sh
Rscript scripts/process_billionaires_data.R
```
