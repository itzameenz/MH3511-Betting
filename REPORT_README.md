# Survival on the RMS Titanic: Exploratory and Inferential Analysis of Passenger Data

**MH3511 — Data Analysis with Computer**  
**Group project (coursework)**

| | |
|:---|:---|
| **Students** | *[Replace with all five group members’ names and student IDs as required by your instructor.]* |
| **Date submitted** | *[Replace.]* |
| **Software** | R (see §6.1 for `sessionInfo()` from a full pipeline run) |

**Declaration — use of generative AI (MH3511 requirement)**  
*[Edit this paragraph to match what your group actually did. Example:]* “Spelling, grammar, and readability were assisted using **[name the tool, e.g. ChatGPT, Copilot, Grammarly]**. All statistical analysis, coding, numerical results, and substantive interpretation were produced by the authors in **R** using the scripts in this repository. The authors are responsible for the accuracy of all reported statistics and figures.”

---

> **Submitting to Word / PDF**  
> Paste this file into Microsoft Word. Insert each figure from [`output/figures/`](output/figures/) at the matching callout (see §3–§4). Replace the two bracketed lines in the table above. Aim for **15–17 pages** of body text, tables, and figures **excluding** appendix and any pasted R code. A full console transcript from a reproducible run is saved as [`output/analysis_console_log.txt`](output/analysis_console_log.txt).

---

## Abstract

The sinking of the RMS Titanic in 1912 produced extensive historical records of passengers and crew. This report analyses a standard passenger-level dataset (891 observations) describing survival outcome and covariates including ticket class, sex, age, family structure, fare, and embarkation port. The analysis proceeds in four stages: (1) data description and cleaning with documented imputation rules and derived variables; (2) exploratory summaries and visualisations; (3) formal hypothesis tests for associations with survival; and (4) a multivariable logistic regression model reporting adjusted odds ratios, together with an **80/20 stratified** train–test evaluation at a 0.5 probability threshold (with accuracy, sensitivity, and specificity). Results are interpreted as **statistical associations** in observational data, not causal effects. Female sex and higher class are strongly associated with higher survival in bivariate and adjusted models; age is negatively associated with survival after adjustment, while the bivariate age comparison by Wilcoxon is not significant at α = 0.05. **Fare** is not significant in the adjusted model alongside class, consistent with overlap between fare and class. The predictive exercise shows moderate test-set performance and underscores the distinction between explanatory modelling and prediction.

---

## Contents

1. **Introduction**  
2. **Data Description**  
3. **Description and Cleaning of Dataset**  
   - 3.1 Summary statistics for the main variable of interest (Survival)  
   - 3.2 Summary statistics for other variables  
   - 3.3 Final dataset for analysis and cleaned data output  
4. **Statistical Analysis**  
   - 4.0 Assumptions and diagnostic checks  
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

### 2.1 Source, justification, and unit of observation

| | |
|:---|:---|
| **Source** | Kaggle, *Titanic — Machine Learning from Disaster* — training split CSV (same structure as many public mirrors). Direct competition page: https://www.kaggle.com/competitions/titanic |
| **Unit** | One row per **passenger** (891 rows in the file used here). |
| **Outcome** | `Survived` — coded **0** (did not survive) and **1** (survived). |

**Why this dataset**  
We chose the Titanic passenger file because it meets course requirements (**at least five variables** of **mixed types**: binary, nominal, ordinal, continuous, count, text) while supporting clear **research questions** about **testing** (associations with survival), **comparison** (groups such as sex and class), and **estimation** (e.g. proportion male among survivors with a confidence interval). It is well documented, easy to obtain, and small enough to run entirely in **R** on any laptop with reproducible scripts.

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

Run **`R/sec03_03__final_dataset_dimensions_and_variable_dictionary.R`** and paste the console **`summary()`** / **`str()`** output into the **Appendix** if the marker requires it (a full pipeline log including this output is in **`output/analysis_console_log.txt`** after `source("R/run_all_analysis.R")`). Key **EDA** numbers for **Survived** (from `R/sec03_01__…`): overall proportions are approximately **61.6%** died (**0**) and **38.4%** survived (**1**).

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

### 4.0 Assumptions and diagnostic checks

Formal inference requires stating what each procedure assumes and what we checked in the data. The table below links methods used in §4.1–§4.4 to **assumptions**, **evidence from this project** (figures / summaries), and **limitations**.

| Method | Main assumptions (relevant here) | What we checked | Limitation / caveat |
|--------|-----------------------------------|-----------------|---------------------|
| **Pearson correlation** (§4.1) | Pairs are comparable; correlation measures **linear** association. | Correlation matrix + scatterplot (**Figure 4.1**); **Fare** is **right-skewed**, so correlation with **Fare** is descriptive, not a full model assumption. | Skewed fares can inflate or mask linear correlation; **Fare_per_person** used in EDA. |
| **Chi-squared / Fisher** (§4.2) | Independent passengers (rows); **expected counts** adequate for asymptotic χ² (or use simulation / exact test). | **Pclass**, **Sex**, **Solo**, **Embarked**: tables are sparse enough that R’s standard χ² is used where appropriate; **FamilySize × Survived** uses **Monte Carlo** χ² (`simulate.p.value = TRUE`, *B* = 10,000) because some expected cells are small; **same-ticket 2×2** uses **Fisher’s exact** test. | Passengers on the same ticket are **not** strictly independent for χ² on the full sample; the party analysis restricts to a **derived** subset and interprets association cautiously. |
| **Wilcoxon rank-sum** (§4.2) | Ordinal comparison of two groups without requiring normality. | Used for **Age** and **Fare** vs survival; **Fare** is strongly skewed (histograms §3.2.4), supporting a **nonparametric** comparison rather than a two-sample *t*-test. | Wilcoxon tests a shift in distribution; **age** distributions overlap heavily (violin/boxplot, **Figure 4.2.3**). |
| **Binomial test** (§4.2) | Survivors are exchangeable for the purpose of estimating one proportion. | **95% CI** for proportion male among survivors. | Conditions on surviving; not a marginal population proportion. |
| **Logistic regression** (§4.3) | Independent rows; **logit** link; approximate **linearity of log-odds** in continuous predictors; no **perfect separation**. | **Class** and **Fare** are correlated (Table 4.1); **Fare** is not significant when both are in the model—consistent with **multicollinearity**/overlap. Residual deviance reported in R output. | We do not present Hosmer–Lemeshow or component-residual plots in the pipeline; interpret linearity in **Age** as an approximation. |
| **Train/test holdout** (§4.4) | Test set is **representative**; same data-generating process as train. | **Stratified** sampling on **Survived** keeps similar outcome prevalence in train and test; **set.seed(3511)**. | Single split; **no** cross-validation; threshold **0.5** is arbitrary. |

---

### 4.1 Correlations among continuous variables

We computed **Pearson** correlations among numeric variables (pairwise complete observations). A scatterplot of **Age** versus **Fare**, coloured by survival, illustrates joint variation.

#### Table 4.1 — Pearson correlation matrix (selected numeric variables)

*Reproducible from `R/sec04_01__correlation_matrix_and_scatterplots_continuous.R` (see also `output/analysis_console_log.txt`).*

|  | Age | Fare | SibSp | Parch | FamilySize | Fare_per_person | Ticket_party_size | Survived |
|--|-----|------|-------|-------|------------|-----------------|-------------------|----------|
| **Age** | 1.000 | 0.123 | −0.250 | −0.176 | −0.258 | 0.253 | −0.221 | −0.060 |
| **Fare** | 0.123 | 1.000 | 0.160 | 0.216 | 0.217 | 0.839 | 0.346 | 0.257 |
| **SibSp** | −0.250 | 0.160 | 1.000 | 0.415 | 0.891 | −0.012 | 0.662 | −0.035 |
| **Parch** | −0.176 | 0.216 | 0.415 | 1.000 | 0.783 | 0.060 | 0.593 | 0.082 |
| **FamilySize** | −0.258 | 0.217 | 0.891 | 0.783 | 1.000 | 0.022 | 0.748 | 0.017 |
| **Fare_per_person** | 0.253 | 0.839 | −0.012 | 0.060 | 0.022 | 1.000 | 0.014 | 0.255 |
| **Ticket_party_size** | −0.221 | 0.346 | 0.662 | 0.593 | 0.748 | 0.014 | 1.000 | 0.038 |
| **Survived** | −0.060 | 0.257 | −0.035 | 0.082 | 0.017 | 0.255 | 0.038 | 1.000 |

#### Figure 4.1 — Age vs fare by survival

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_01__scatter_age_fare_survival.png` |
| **Script** | `R/sec04_01__correlation_matrix_and_scatterplots_continuous.R` |
| **Suggested caption** | *Figure 4.1. Passenger fare vs age, by survival status (semi-transparent points).* |

---

### 4.2 Statistical tests

For each test we state **H₀** / **H₁**, report the **test statistic** (where applicable), **p-value**, and a **plain-language** conclusion. All results below match a full run logged in **`output/analysis_console_log.txt`** (*R* 4.5.3, `set.seed` only where noted in §4.4).

| Section | Research focus | R script | Key figure |
|--------|----------------|----------|------------|
| 4.2.1 | Class & fare vs survival | `R/sec04_02_01__statistical_tests_class_fare_and_survival.R` | `fig__sec04_02_01__fare_by_class_survival.png` |
| 4.2.2 | Sex; % male among survivors | `R/sec04_02_02__statistical_tests_sex_and_survivor_composition.R` | `fig__sec04_02_02__sex_survival_counts.png` |
| 4.2.3 | Age vs survival | `R/sec04_02_03__statistical_tests_age_survivors_vs_nonsurvivors.R` | `fig__sec04_02_03__age_violin_survival.png` |
| 4.2.4 | Family size & solo | `R/sec04_02_04__statistical_tests_family_size_solo_travel_survival.R` | `fig__sec04_02_04__solo_survival.png` |
| 4.2.5 | Embarked vs survival | `R/sec04_02_05__statistical_tests_embarked_port_and_survival.R` | `fig__sec04_02_05__embarked_counts.png` |
| 4.2.6 | Same-ticket concordance | `R/sec04_02_06__statistical_tests_same_ticket_party_concordance.R` | `fig__sec04_02_06__ticket_party_mix.png` |

#### 4.2.1 Passenger class and fare vs survival

- **Pclass × Survived (χ²):** H₀: no association. Pearson χ² = **102.89**, df = 2, *p* < 2.2×10⁻¹⁶ → **strong evidence** that survival differs by class (first class higher survival share; see §3.2.1).  
- **Fare by survival (Wilcoxon):** H₀: same distribution of fare. *W* = 57 807, *p* < 2.2×10⁻¹⁶ → fares differ between survivors and non-survivors (consistent with class mixing).

#### 4.2.2 Sex and composition of survivors

- **Sex × Survived (χ² with Yates):** χ² = **260.72**, df = 1, *p* < 2.2×10⁻¹⁶ → survival differs sharply by sex.  
- **Estimation:** Among **342** survivors, proportion **male** = **0.319**. Exact binomial test vs 0.5: *p* = **1.76×10⁻¹¹**; **95% CI** for the proportion male = **[0.270, 0.371]**.

#### 4.2.3 Age vs survival

- **Wilcoxon rank-sum:** *W* = **98 172**, *p* = **0.25** → **no significant difference** in age distributions between survivors and non-survivors at α = 0.05 in this sample (contrast with **adjusted** age effect in §4.3—sex and class confound the marginal age comparison).

#### 4.2.4 Family size and solo travel

- **FamilySize × Survived:** Pearson χ² with **simulated** *p*-value (*B* = 10 000): χ² = **80.67**, *p* = **1.0×10⁻⁴** (reported as 9.999×10⁻⁵ in log).  
- **IsSolo × Survived (Yates χ²):** χ² = **36.00**, df = 1, *p* = **1.97×10⁻⁹** → solo vs not solo is associated with survival.

#### 4.2.5 Embarked port vs survival

- **Embarked × Survived (χ²):** χ² = **25.96**, df = 2, *p* = **2.30×10⁻⁶** → association exists; interpret with **class** mix by port (confounding).

#### 4.2.6 Same-ticket parties (subset analysis)

Among passengers on **multi-passenger tickets**, cross-tab **Self survived × Other in party survived** yields **Fisher’s exact** *p* < 2.2×10⁻¹⁶; estimated **odds ratio** ≈ **9.12** (95% CI **5.41–15.68**) for concordance pattern vs discordance. Party outcome patterns: **all died** 37, **all survived** 48, **mixed** 49 (counts from one full run).

> **Remark — FamilySize × Survived**  
> Monte Carlo χ² is used because some **expected counts** in the full **FamilySize × Survived** table are small.

---

### 4.3 Multiple logistic regression

We fit a **logistic regression** model:

$$\text{logit}\,P(\text{Survived}=1) = \beta_0 + \beta_1 \text{Pclass} + \beta_2 \text{Sex} + \beta_3 \text{Age} + \beta_4 \text{Fare} + \beta_5 \text{Embarked}$$

*`Pclass` is fitted as an **ordered** factor (polynomial contrasts in R: `.L` linear, `.Q` quadratic).*

#### Figure 4.3 — Odds ratios (forest plot)

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_03__logistic_or_forest.png` |
| **Script** | `R/sec04_03__multivariable_logistic_regression_and_odds_ratios.R` |

#### Table 4.2 — Odds ratios and 95% CI (Wald, `confint.default`)

| Term | OR | 95% CI low | 95% CI high | Interpretation (adjusted) |
|------|-----|------------|-------------|---------------------------|
| (Intercept) | 1.315 | 0.680 | 2.543 | — |
| Pclass.L (linear trend) | 0.177 | 0.117 | 0.270 | Strong **negative** association with survival as class increases **1→3**. |
| Pclass.Q | 0.877 | 0.615 | 1.248 | Not significant at α = 0.05. |
| Sex (female vs male) | **12.843** | 8.862 | 18.612 | **Female** passengers have much higher odds of survival, holding other covariates fixed. |
| Age (per year) | **0.965** | 0.950 | 0.979 | Each additional year of age is associated with **lower** odds of survival. |
| Fare | 0.9999 | 0.9957 | 1.004 | **Not** significant (*z* ≈ −0.07, *p* ≈ 0.95)—overlap with **class** (see Table 4.1). |
| Embarked Q vs C | 0.930 | 0.449 | 1.926 | Not significant. |
| Embarked S vs C | 0.596 | 0.375 | 0.948 | **Southampton** vs **Cherbourg** lower odds at α = 0.05. |

**Model fit (printout):** Null deviance **1186.66** on **890** df; residual deviance **795.58** on **883** df; AIC **811.58**.

---

### 4.4 Predictive performance (train/test split)

We allocated **80%** of passengers to **training** and **20%** to **testing** using **`set.seed(3511)`**. Sampling is **stratified on `Survived`**: within each outcome stratum we draw **80%** at random, so **train** and **test** retain similar survival rates (on our run: train **0.383**, test **0.386**). The fitted model is `Survived ~ Pclass + Sex + Age + Fare` (slightly smaller than §4.3 so the predictive script stays stable). Predicted probabilities on the test set use threshold **0.5**.

#### Figure 4.4 — Confusion matrix (test set)

| | |
|:---|:---|
| **File** | `output/figures/fig__sec04_04__confusion_matrix.png` |
| **Script** | `R/sec04_04__predictive_train_test_glm_confusion_matrix_roc.R` |

#### Table 4.3 — Holdout performance (*n*\_test = 179 after stratified split)

| Metric | Value |
|--------|--------|
| **Confusion matrix** (rows = actual) | Pred 0: (actual 0) **89**, (actual 1) **21**; Pred 1: (actual 0) **21**, (actual 1) **48** |
| **Accuracy** (threshold 0.5) | **0.765** |
| **Sensitivity** (recall, actual survived) | **0.696** |
| **Specificity** (actual not survived) | **0.809** |

**Limitations:** Single split; **no** cross-validation; threshold fixed at **0.5**; **no** ROC/AUC in the default script (optional extension: package **pROC** or a manual threshold sweep).

---

## 5. Conclusion and Discussion

This report examined survival among Titanic passengers using transparent cleaning rules (median imputation for **Age** and **Fare**, modal **Embarked**, derived **Title**, **FamilySize**, **Fare_per_person**, **Deck**, **Ticket_party_size**) and a reproducible **R** pipeline. Below we map each **objective** from §1.1 to the **evidence** obtained.

| # | Objective (§1.1) | Evidence |
|---|------------------|----------|
| 1 | Class and fare vs survival | **χ²** on **Pclass × Survived** (*p* < 10⁻¹⁵); **Wilcoxon** on **Fare** (*p* < 10⁻¹⁵). |
| 2 | Sex and age vs survival | **Sex × Survived** χ² (*p* < 10⁻¹⁵); **Age** Wilcoxon **not** significant marginally (*p* = 0.25) but **age** is significant **after adjustment** in logistic regression (Table 4.2). |
| 3 | Proportion male among survivors | **Point estimate 0.319**; binomial **95% CI [0.270, 0.371]**; strongly below 0.5. |
| 4 | Family size and solo travel | **FamilySize** table: Monte Carlo χ² *p* ≈ 10⁻⁴; **IsSolo** χ² *p* ≈ 2×10⁻⁹. |
| 5 | Embarkation vs survival | **Embarked × Survived** χ² *p* ≈ 2.3×10⁻⁶; caution on **confounding** with class. |
| 6 | Same-ticket concordance | **Fisher** exact *p* < 10⁻¹⁵; **OR** ≈ 9.1 on the multi-ticket subset. |
| 7 | Multivariable synthesis | **Female** OR ≈ **12.8**; **class** linear contrast OR ≈ **0.18** per ordered step; **age** OR **0.965**/year; **Fare** not significant adjusted for class. |
| 8 | Prediction | **Stratified** 80/20 holdout: **accuracy 0.77**, **sensitivity 0.70**, **specificity 0.81** (Table 4.3). |

Overall, results align with historical narratives (**women** and **higher class** fare better in this manifest) while illustrating statistical nuance: **marginal** age patterns can differ from **adjusted** age effects, and **fare** overlaps **class** in a multivariable model. The **predictive** exercise shows **moderate** test performance and underscores that **explanatory** strength (large ORs) and **classification accuracy** need not match. Future work could add **cross-validated AUC**, **alternative thresholds**, or **interaction** terms (e.g. sex × class) if the course permits.

---

## 6. Appendix

### 6.1 Reproducibility

| Step | Location |
|------|----------|
| Cleaning | `data_cleaning/clean_and_save_titanic.R` |
| Full analysis driver | `R/run_all_analysis.R` |
| Console transcript | `output/analysis_console_log.txt` (full numerical output from one run) |

**`sessionInfo()`** (from `R/sec99__session_info_for_reproducibility.R`, logged in `output/analysis_console_log.txt`):

```
R version 4.5.3 (2026-03-11 ucrt)
Platform: x86_64-w64-mingw32/x64
Running under: Windows 11 x64 (build 26200)

Matrix products: default
  LAPACK version 3.12.1

locale:
[1] LC_COLLATE=English_India.utf8  LC_CTYPE=English_India.utf8   
[3] LC_MONETARY=English_India.utf8 LC_NUMERIC=C                  
[5] LC_TIME=English_India.utf8    

time zone: Asia/Singapore
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] ggplot2_4.0.2

loaded via a namespace (and not attached):
 [1] labeling_0.4.3     scales_1.4.0       compiler_4.5.3     R6_2.6.1          
 [5] cli_3.6.5          tools_4.5.3        withr_3.0.2        RColorBrewer_1.1-3
 [9] glue_1.8.0         gtable_0.3.6       farver_2.1.2       vctrs_0.7.2       
[13] grid_4.5.3         S7_0.2.1           lifecycle_1.0.5    rlang_1.1.7       
```

*If you rerun on another machine, replace this block with your own `sessionInfo()` output.*

### 6.2 Full cleaned data

The complete cleaned dataset is **`data/titanic_cleaned.csv`** (891 rows). For the submitted report, the **sample in §3.0.3** plus this appendix reference is usually sufficient unless the marker requests the full table in print.

### 6.3 GenAI and writing assistance

See the **Declaration — use of generative AI** at the top of this document (also repeat on the **title page** of the submitted PDF if your instructor requires both).

---

## 7. References

1. Kaggle. *Titanic — Machine Learning from Disaster* (competition data). https://www.kaggle.com/competitions/titanic (access date: *[insert]*).  
2. R Core Team (2026). *R: A language and environment for statistical computing.* R Foundation for Statistical Computing, Vienna, Austria. https://www.R-project.org/  
3. Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis.* Springer-Verlag New York. https://ggplot2.tidyverse.org/

---

*End of REPORT_README.md*
