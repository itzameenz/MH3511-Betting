# Survival on the RMS Titanic: Exploratory and Inferential Analysis of Passenger Data

---

| | |
|:---|:---|
| **Module** | MH3511 — Data Analysis with Computer |
| **Project type** | Group project (coursework) |
| **Software** | R (see Appendix for `sessionInfo()`) |

---

> **Note for submission**  
> Paste this document into Microsoft Word; insert figures from `output/figures/` at each figure callout. Replace bracketed placeholders (e.g. group member names, declaration of GenAI use on the title page per course policy).

---

## Abstract

The sinking of the RMS Titanic in 1912 produced extensive historical records of passengers and crew. This report analyses a standard passenger-level dataset (891 observations) describing survival outcome and covariates including ticket class, sex, age, family structure, fare, and embarkation port. The analysis proceeds in four stages: (1) data description and cleaning with documented imputation rules and derived variables; (2) exploratory summaries and visualisations; (3) formal hypothesis tests for associations with survival; and (4) a multivariable logistic regression model reporting adjusted odds ratios, together with a simple 80/20 train–test evaluation of out-of-sample classification accuracy at a 0.5 probability threshold. Results are interpreted as **statistical associations** in observational data, not causal effects. Female sex and higher class are strongly associated with higher survival rates in both bivariate and adjusted models; age remains negatively associated with survival after adjustment. The predictive exercise illustrates moderate test-set accuracy and highlights the distinction between explanatory modelling and prediction.

---

## Contents

1. **Introduction**  
2. **Data Description**  
3. **Description and Cleaning of Dataset**  
   - 3.1 Summary statistics for the main variable of interest (Survival)  
   - 3.2 Summary statistics for other variables  
   - 3.3 Final dataset for analysis and cleaned data output  
4. **Statistical Analysis**  
   - 4.1 Correlations among continuous variables  
   - 4.2 Statistical tests  
   - 4.3 Multiple logistic regression  
   - 4.4 Predictive performance (train/test split)  
5. **Conclusion and Discussion**  
6. **Appendix**  
7. **References**  

---

## 1. Introduction

The RMS Titanic sank on 15 April 1912 during her maiden voyage after a collision with an iceberg. Limited lifeboat capacity meant that not all passengers could be evacuated; historical accounts and subsequent research suggest that **women and children**, and passengers of **higher socioeconomic status**, were more likely to survive. Modern tabulations of passenger manifests allow these hypotheses to be examined quantitatively.

### 1.1 Project objectives

This project addresses the following questions:

1. **Socioeconomic position:** Are **passenger class** and **fare** associated with survival?  
2. **Demographics:** Are **sex** and **age** associated with survival?  
3. **Composition of survivors:** Among passengers who **survived**, what proportion are **male**, and what is an appropriate confidence interval?  
4. **Family structure:** Is **family size** or **solo travel** associated with survival?  
5. **Embarkation:** Is **port of embarkation** associated with survival (interpreted cautiously given confounding with class)?  
6. **Travel parties:** For passengers sharing the same **ticket** (a proxy for a joint travel party), is one individual’s survival associated with another party member’s survival?  
7. **Multivariable synthesis:** After mutual adjustment, which factors remain associated with survival (odds ratios from logistic regression)?  
8. **Prediction:** How well does a logistic model predict survival on a **held-out** test sample?

### 1.2 Methods overview

We follow the structure recommended for MH3511 project work: exploratory analysis with graphical checks, explicit statement of assumptions where relevant, application of appropriate tests (chi-squared, Wilcoxon rank-sum, Fisher’s exact test as warranted), multivariable **generalised linear modelling** with binomial family (logistic regression), and a brief **predictive** evaluation using a stratified random split. All computation is reproducible from the accompanying R scripts.

### 1.3 Limitations

The data are **observational**. Associations do not imply causation. Missing **cabin** information is extensive; we derive **deck** where possible but retain an “unknown” category. The **same-ticket** grouping is a proxy for family or joint booking, not a perfect map to kinship.

---

## 2. Data Description

### 2.1 Source and unit of observation

| | |
|:---|:---|
| **Source** | [Insert: e.g. Kaggle “Titanic — Machine Learning from Disaster” competition training file, or course-provided extract.] |
| **Unit** | One row per **passenger** (891 rows in the file used here). |
| **Outcome** | `Survived` — coded **0** (did not survive) and **1** (survived). |

### 2.2 Variable dictionary (raw file)

| Variable | Description | Type |
|----------|-------------|------|
| `PassengerId` | Row identifier | Integer |
| `Survived` | Survival indicator | Binary (0/1) |
| `Pclass` | Ticket class | Ordinal (1 = first, 2 = second, 3 = third) |
| `Name` | Full name (string) | Text |
| `Sex` | Sex | Binary (male / female) |
| `Age` | Age in years | Continuous (years); missing in some rows |
| `SibSp` | Siblings/spouses aboard | Count |
| `Parch` | Parents/children aboard | Count |
| `Ticket` | Ticket identifier | Text (links passengers on same purchase) |
| `Fare` | Passenger fare | Continuous |
| `Cabin` | Cabin code | Text (often missing) |
| `Embarked` | Port of embarkation | Categorical (C = Cherbourg, Q = Queenstown, S = Southampton) |

---

## 3. Description and Cleaning of Dataset

### 3.0 Cleaning procedure (summary)

All cleaning is implemented in **`data_cleaning/clean_and_save_titanic.R`** and documented in **`data_cleaning/README.md`**. The README’s section **Cleaned dataset output** repeats the column dictionary, raw-vs-clean missingness, and a sample table in one place for markers and teammates. The workflow is:

1. Read **`data/Titanic-Dataset.csv`**.  
2. Impute **Embarked** (blank/missing) with the **modal** port among non-missing passengers.  
3. Impute **Age**: for each **Pclass × Sex** stratum, replace missing values with the stratum **median**; any remaining missing values receive the **global** median age.  
4. Impute **Fare**: within each **Pclass**, use the class **median**; then global median if needed.  
5. Derive **Title** from **Name** (substring between the comma and the first full stop).  
6. Compute **FamilySize** = `SibSp + Parch + 1`, and **IsSolo** = 1 if `FamilySize == 1`, else 0.  
7. Compute **Ticket_party_size** = number of passengers sharing the same **Ticket**; **Fare_per_person** = `Fare / Ticket_party_size`.  
8. Derive **Deck** = first character of **Cabin**; if cabin missing or empty, set **Deck** = **U** (unknown).  
9. Set variable types for analysis (`Survived` integer; `Sex`, `Embarked`, `Pclass` as factors; `Pclass` ordered).  
10. Sort rows by **`PassengerId`** and write **`data/titanic_cleaned.csv`**.

> **Readable narrative**  
> For a fuller **word explanation** of why these rules are used (embarked mode, median imputation, derived fields, what is left missing), see **`data_cleaning/README.md`** → section **What the cleaning does (in plain language)**.

### 3.0.1 Missingness before and after cleaning (raw vs cleaned)

In the **raw** file used for this project, non-response patterns were:

| Variable | Number missing / blank (raw, *n* = 891) |
|----------|----------------------------------------|
| `Cabin` | 687 |
| `Age` | 177 |
| `Embarked` | 2 |
| `Fare` | 0 |

After cleaning, **Age**, **Fare**, and **Embarked** contain **no missing values** in the analytic file. **`Cabin`** may still be missing in the stored CSV (unchanged); analysis uses **Deck** with **U** for unknown cabin. Scripts that require complete **Age** / **Fare** / **Embarked** therefore use the cleaned file only.

### 3.0.2 Cleaned data output — file and dimensions

| | |
|:---|:---|
| **Output file** | `data/titanic_cleaned.csv` |
| **Dimensions** | **891 rows × 18 columns** (same passengers as raw; new derived columns added). |

**Column list (cleaned file):**  
`Ticket`, `PassengerId`, `Survived`, `Pclass`, `Name`, `Sex`, `Age`, `SibSp`, `Parch`, `Fare`, `Cabin`, `Embarked`, `Title`, `FamilySize`, `IsSolo`, `Ticket_party_size`, `Fare_per_person`, `Deck`.

### 3.0.3 Cleaned data output — sample rows (first 10 passengers)

The table below is taken directly from **`titanic_cleaned.csv`** after cleaning (illustrative; full data remain in the CSV). *Name* is truncated for layout.

| PassengerId | Survived | Pclass | Sex | Age | Fare | Embarked | Title | FamilySize | IsSolo | Ticket_party_size | Fare_per_person | Deck |
|-------------|----------|--------|-----|-----|------|----------|-------|------------|--------|-------------------|-----------------|------|
| 1 | 0 | 3 | male | 22 | 7.25 | S | Mr | 2 | 0 | 1 | 7.25 | U |
| 2 | 1 | 1 | female | 38 | 71.28 | C | Mrs | 2 | 0 | 1 | 71.28 | C |
| 3 | 1 | 3 | female | 26 | 7.93 | S | Miss | 1 | 1 | 1 | 7.93 | U |
| 4 | 1 | 1 | female | 35 | 53.10 | S | Mrs | 2 | 0 | 2 | 26.55 | C |
| 5 | 0 | 3 | male | 35 | 8.05 | S | Mr | 1 | 1 | 1 | 8.05 | U |
| 6 | 0 | 3 | male | 25 | 8.46 | Q | Mr | 1 | 1 | 1 | 8.46 | U |
| 7 | 0 | 1 | male | 54 | 51.86 | S | Mr | 1 | 1 | 1 | 51.86 | E |
| 8 | 0 | 3 | male | 2 | 21.08 | S | Master | 5 | 0 | 4 | 5.27 | U |
| 9 | 1 | 3 | female | 27 | 11.13 | S | Mrs | 3 | 0 | 3 | 3.71 | U |
| 10 | 1 | 2 | female | 14 | 30.07 | C | Mrs | 2 | 0 | 2 | 15.04 | U |

*Note:* Row 4 shares a ticket with another passenger (`Ticket_party_size` = 2), so **Fare_per_person** is half of total fare. Row 8 shows a larger party on one ticket (`Ticket_party_size` = 4).

### 3.0.4 Cleaned data — numeric summaries (for the report body)

Run **`R/sec03_03__final_dataset_dimensions_and_variable_dictionary.R`** and paste the console **`summary()`** / **`str()`** output into the **Appendix** if the marker requires it. Key **EDA** numbers for **Survived** (from `R/sec03_01__…`): overall proportions are approximately **61.6%** died (**0**) and **38.4%** survived (**1**).

---

### 3.1 Summary statistics for the main variable of interest (Survival)

The outcome **Survived** is binary. A bar chart of counts shows the imbalance toward non-survival in this sample.

#### Figure 3.1 — Overall survival counts

| | |
|:---|:---|
| **File** | `output/figures/fig__sec03_01__survival_overall.png` |
| **Produced by** | `R/sec03_01__eda_main_outcome_survival_barplot_and_rates.R` |
| **Explainer** | `rcode_explain/sec03_01__eda_main_outcome_survival_barplot_and_rates.md` |
| **Suggested caption** | *Figure 3.1. Counts of passengers by survival status (0 = did not survive, 1 = survived).* |

---

### 3.2 Summary statistics for other variables

For each subsection, we examined tabulations, appropriate plots, and (where noted) transformations. Full code and short explainers sit in **`R/`** and **`rcode_explain/`**.

| § | Topic | Figure(s) | R script |
|---|--------|-----------|----------|
| **3.2.1** | Passenger class (`Pclass`) | `output/figures/fig__sec03_02_01__passenger_class_distribution.png` | `R/sec03_02_01__eda_passenger_class_tables_and_barplots.R` |
| **3.2.2** | Sex | `output/figures/fig__sec03_02_02__sex_survival_share.png` | `R/sec03_02_02__eda_sex_tables_and_barplots.R` |
| **3.2.3** | Age (post-cleaning: no missing) | `output/figures/fig__sec03_02_03__age_histogram_by_survival.png`, `output/figures/fig__sec03_02_03__age_boxplot_by_survival.png` | `R/sec03_02_03__eda_age_histogram_boxplot_missingness.R` |
| **3.2.4** | Fare and fare per person | `output/figures/fig__sec03_02_04__fare_histogram.png`, `output/figures/fig__sec03_02_04__fare_per_person_boxplot.png` | `R/sec03_02_04__eda_fare_histogram_fare_per_person_boxplots.R` |
| **3.2.5** | Family size and solo travel | `output/figures/fig__sec03_02_05__family_size_survival.png` | `R/sec03_02_05__eda_family_size_sibsp_parch_solo_vs_group.R` |
| **3.2.6** | Embarked | `output/figures/fig__sec03_02_06__embarked_survival.png` | `R/sec03_02_06__eda_embarked_port_barplots.R` |
| **3.2.7** | Title, deck, ticket party size | `output/figures/fig__sec03_02_07__title_survival.png` | `R/sec03_02_07__eda_ticket_cabin_derived_title_deck_party_size.R` |

*Fare is right-skewed; **Fare_per_person** adjusts for shared tickets.*

**Figure numbering (same as before):** **[Figure 3.2.1]** class; **[Figure 3.2.2]** sex; **[Figures 3.2.3a–b]** age histogram and boxplot; **[Figures 3.2.4a–b]** fare histogram and fare-per-person boxplot; **[Figure 3.2.5]** family size; **[Figure 3.2.6]** embarked; **[Figure 3.2.7]** title (and related derived fields in that script).

---

### 3.3 Final dataset for analysis

The **final analytic dataset** is **`titanic_cleaned.csv`**, **891 × 18**, as listed in §3.0.2–3.0.3. All subsequent models and tests read this file via **`R/bootstrap_paths.R`** and **`load_titanic_clean()`**.

---

## 4. Statistical Analysis

### 4.1 Correlations among continuous variables

We computed Pearson correlations among numeric variables (pairwise complete observations). A scatterplot of **Age** versus **Fare**, coloured by survival, illustrates joint variation.

#### Figure 4.1 — Age vs fare by survival

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_01__scatter_age_fare_survival.png` |
| **Script** | `R/sec04_01__correlation_matrix_and_scatterplots_continuous.R` |

**[Insert table]** Copy the printed **correlation matrix** from the R console into this section as Table 4.1.

---

### 4.2 Statistical tests

For each test, report **null and alternative hypotheses**, the **test statistic**, **p-value**, and a **plain-language conclusion**. Where chi-squared tests involve small expected counts, note the limitation or use an exact test (Fisher) where implemented.

| Section | Research focus | R script | Key figure |
|--------|----------------|----------|------------|
| 4.2.1 | Class & fare vs survival | `R/sec04_02_01__statistical_tests_class_fare_and_survival.R` | `fig__sec04_02_01__fare_by_class_survival.png` |
| 4.2.2 | Sex; % male among survivors | `R/sec04_02_02__statistical_tests_sex_and_survivor_composition.R` | `fig__sec04_02_02__sex_survival_counts.png` |
| 4.2.3 | Age vs survival | `R/sec04_02_03__statistical_tests_age_survivors_vs_nonsurvivors.R` | `fig__sec04_02_03__age_violin_survival.png` |
| 4.2.4 | Family size & solo | `R/sec04_02_04__statistical_tests_family_size_solo_travel_survival.R` | `fig__sec04_02_04__solo_survival.png` |
| 4.2.5 | Embarked vs survival | `R/sec04_02_05__statistical_tests_embarked_port_and_survival.R` | `fig__sec04_02_05__embarked_counts.png` |
| 4.2.6 | Same-ticket concordance | `R/sec04_02_06__statistical_tests_same_ticket_party_concordance.R` | `fig__sec04_02_06__ticket_party_mix.png` |

**[Paste R output]** Insert chi-squared, Wilcoxon, binomial, and Fisher outputs from each script.

> **Remark — FamilySize × Survived**  
> Pearson’s χ² uses a **Monte Carlo simulated p-value** (`simulate.p.value = TRUE`) because some expected counts in the full table are small; report the printed p-value and note the method in the methods paragraph if your marker requires it.

---

### 4.3 Multiple logistic regression

We fit a **logistic regression** model:

$$\text{logit}\,P(\text{Survived}=1) = \beta_0 + \beta_1 \text{Pclass} + \beta_2 \text{Sex} + \beta_3 \text{Age} + \beta_4 \text{Fare} + \beta_5 \text{Embarked}$$

#### Figure 4.3 — Odds ratios (forest plot)

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_03__logistic_or_forest.png` |
| **Script** | `R/sec04_03__multivariable_logistic_regression_and_odds_ratios.R` |

**[Paste table]** Exponentiated coefficients (**odds ratios**) and **95% confidence intervals** from R output.

**Interpretation (to refine with your exact output):** After adjustment, **female** sex and **higher class** (ordered factor contrasts) are typically associated with **higher** odds of survival; **age** often shows **lower** odds per additional year. **Fare** may be **collinear** with class; interpret cautiously when both are in the model.

---

### 4.4 Predictive performance (train/test split)

We used **80%** of passengers for **training** and **20%** for **testing**, with **`set.seed(3511)`** for reproducibility. The model was `Survived ~ Pclass + Sex + Age + Fare`. Predicted probabilities on the test set were classified at threshold **0.5**.

#### Figure 4.4 — Confusion matrix (test set)

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_04__confusion_matrix.png` |
| **Script** | `R/sec04_04__predictive_train_test_glm_confusion_matrix_roc.R` |

**[Paste metrics]** Confusion matrix, accuracy, and (optional) sensitivity/specificity from your run.

**Limitations:** Single random split; no cross-validation; threshold fixed at 0.5; no ROC/AUC in the default script (can be added with package **pROC** if desired).

---

## 5. Conclusion and Discussion

This report examined survival among Titanic passengers using cleaning rules that impute missing **Age**, **Fare**, and **Embarked**, and derived variables (**Title**, **FamilySize**, **Fare_per_person**, **Deck**, **Ticket_party_size**) for richer description. Bivariate and multivariable analyses broadly align with historical narratives: **women** and **first-class** passengers tended to show **higher** survival rates, and **age** remains relevant in the adjusted model. **Embarkation** associations should be interpreted alongside **class** composition by port. The **same-ticket** analysis suggests **concordance** of survival within travel parties, consistent with families staying together, though ticket groups are not purely familial.

The **predictive** subsection illustrates **moderate** test accuracy and underscores that **explanatory** strength (odds ratios) and **predictive** performance need not coincide. Future work could add **cross-validated AUC**, **alternative thresholds**, or **interaction terms** (e.g. sex × class) if the course permits.

---

## 6. Appendix

### 6.1 Reproducibility

| Step | Location |
|------|----------|
| Cleaning | `data_cleaning/clean_and_save_titanic.R` |
| Full analysis driver | `R/run_all_analysis.R` |
| Session information | Run `R/sec99__session_info_for_reproducibility.R` and paste output below. |

```
[Paste sessionInfo() output here]
```

### 6.2 Full cleaned data

The complete cleaned dataset is **`data/titanic_cleaned.csv`** (891 rows). For the submitted report, the **sample in §3.0.3** plus this appendix reference is usually sufficient unless the marker requests the full table in print.

### 6.3 GenAI and writing assistance

[Required by course: declare use of GenAI for grammar/polish on the **title page** of the final PDF, per MH3511 instructions.]

---

## 7. References

1. Titanic passenger data (state exact source URL or Kaggle citation).  
2. R Core Team (year). *R: A language and environment for statistical computing.* R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/  
3. Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis.* Springer-Verlag New York (or cite `citation("ggplot2")` from R).

---

*End of REPORT_README.md*
