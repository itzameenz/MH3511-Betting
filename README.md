# Betting Odds Data Project

This repository contains the raw betting odds dataset, a cleaned dataset, and the R script used to generate the cleaned output.

## Project structure

- `data/raw/closing_odds.csv` - raw input dataset
- `data/cleaned/cleaned_betting_data.csv` - cleaned output dataset
- `data_cleaning/cleaning_data.R` - cleaning script

## Run the cleaning script

From the project root in R:

```r
source("data_cleaning/cleaning_data.R")
```

The script reads `data/raw/closing_odds.csv` and writes `data/cleaned/cleaned_betting_data.csv`.
