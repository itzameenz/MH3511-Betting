# R code explainers (`rcode_explain/`)

Each **`.md` file** matches one **`.R` script** by basename. Read the explainer first if you are not comfortable reading R.

| Script | Report area | One-line purpose |
|--------|-------------|------------------|
| `data_cleaning/clean_and_save_titanic.R` | §3 cleaning | Raw CSV → `data/titanic_cleaned.csv` |
| `R/sec03_01__…` | §3.1 | Survival outcome bar chart + rates |
| `R/sec03_02_01__…` | §3.2.1 | Pclass tables + stacked bar |
| `R/sec03_02_02__…` | §3.2.2 | Sex tables + stacked bar |
| `R/sec03_02_03__…` | §3.2.3 | Age histograms + boxplot |
| `R/sec03_02_04__…` | §3.2.4 | Fare + fare-per-person plots |
| `R/sec03_02_05__…` | §3.2.5 | Family size / solo EDA |
| `R/sec03_02_06__…` | §3.2.6 | Embarked EDA |
| `R/sec03_02_07__…` | §3.2.7 | Title / deck / party size EDA |
| `R/sec03_03__…` | §3.3 | Dimensions + `str()` |
| `R/sec04_01__…` | §4.1 | Correlation + scatter |
| `R/sec04_02_01__…` | §4.2.1 | χ² Pclass; Wilcoxon fare |
| `R/sec04_02_02__…` | §4.2.2 | χ² sex; binom CI % male survivors |
| `R/sec04_02_03__…` | §4.2.3 | Wilcoxon age |
| `R/sec04_02_04__…` | §4.2.4 | χ² family size & solo |
| `R/sec04_02_05__…` | §4.2.5 | χ² embarked |
| `R/sec04_02_06__…` | §4.2.6 | Fisher concordance; party mix |
| `R/sec04_03__…` | §4.3 | Multivariable logistic + OR plot |
| `R/sec04_04__…` | §4.4 | 80/20 train-test + confusion matrix |
| `R/sec99__…` | Appendix | `sessionInfo()` |

**Run order:** always run **`data_cleaning/clean_and_save_titanic.R`** once before any `R/sec*.R` script.

**Shortcut:** from project root, `source("R/run_all_analysis.R")` runs cleaning then every `R/sec*.R` in order (skips `bootstrap_paths.R`).
