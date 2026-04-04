# Explainer: `R/sec04_02_01__statistical_tests_class_fare_and_survival.R`

- **§4.2.1** — class & fare vs survival.
- **Tests:** `chisq.test` on **Pclass × Survived**; `wilcox.test` **Fare** by survival (nonparametric).
- **Figure:** fare by class, faceted by survival (log10 y); **zero fares** are shifted to `min(positive Fare)/10` for the log scale only (Wilcoxon still uses raw `Fare`).
