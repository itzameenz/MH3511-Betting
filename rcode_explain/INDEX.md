# R code explainers (`rcode_explain/`)

Each **`.md` file** matches one **`.R` script** (same base name). Besides the table below, **open the matching explainer** for a **long written explanation** (what the script does in words, what to copy from the console, how to describe figures, and statistical caveats).

**How each explainer is structured**

| Block | Meaning |
|--------|--------|
| **Report** | Which part of `REPORT_README.md` this supports |
| **One line** | Plain-language goal |
| **Before you run** | Working directory + files you need |
| **What the script does** | Logic in words |
| **Console** | Copy-paste candidates for the report |
| **Figures** | `output/figures/...` (skipped if **ggplot2** not installed) |
| **Write-up** | Interpretation and caveats |

**Run order:** run **`data_cleaning/clean_and_save_titanic.R`** once, then any `R/sec*.R`, or use **`source("R/run_all_analysis.R")`** from the project root.

---

## Index (script → report)

| Script | Report | One-line purpose |
|--------|--------|------------------|
| `data_cleaning/clean_and_save_titanic.R` | §3 cleaning | Raw CSV → `data/titanic_cleaned.csv` |
| `R/sec03_01__…` | §3.1 | Survival bar chart + overall rates |
| `R/sec03_02_01__…` | §3.2.1 | Pclass tables + survival share bar |
| `R/sec03_02_02__…` | §3.2.2 | Sex tables + survival share bar |
| `R/sec03_02_03__…` | §3.2.3 | Age summary + histogram + boxplot |
| `R/sec03_02_04__…` | §3.2.4 | Fare / fare-per-person summaries + plots |
| `R/sec03_02_05__…` | §3.2.5 | Family size / solo EDA |
| `R/sec03_02_06__…` | §3.2.6 | Embarked EDA |
| `R/sec03_02_07__…` | §3.2.7 | Title / deck / party size EDA |
| `R/sec03_02_08__…` | §3.2.8 | SES_band vs survival (faceted by class) |
| `R/sec03_03__…` | §3.3 | Row/column count + `str()` |
| `R/sec04_01__…` | §4.1 | Correlation matrix + Age–Fare scatter |
| `R/sec04_02_01__…` | §4.2.1 | χ² Pclass; Wilcoxon fare; fare boxplots |
| `R/sec04_02_02__…` | §4.2.2 | χ² sex; binomial CI for % male survivors |
| `R/sec04_02_03__…` | §4.2.3 | Wilcoxon age; violin plot |
| `R/sec04_02_04__…` | §4.2.4 | χ² family size (simulated *p*) & solo |
| `R/sec04_02_05__…` | §4.2.5 | χ² embarked; dodged count bar |
| `R/sec04_02_06__…` | §4.2.6 | Fisher same-ticket concordance; party mix |
| `R/sec04_02_07__…` | §4.2.7 | χ² SES_band × Survived; count bar |
| `R/sec04_03__…` | §4.3 | Multivariable logistic + OR forest plot |
| `R/sec04_04__…` | §4.4 | 80/20 split + confusion matrix + accuracy |
| `R/sec99__…` | Appendix | Paths + `sessionInfo()` |

**Shared setup:** every `R/sec*.R` sources **`R/bootstrap_paths.R`** and calls **`load_titanic_clean()`** (reads `data/titanic_cleaned.csv`).
