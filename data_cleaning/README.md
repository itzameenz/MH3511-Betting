# Data cleaning — Titanic passenger file

This folder contains **only** the pipeline that turns the **raw** CSV into the **cleaned** CSV used for all analysis. All scripts under **`R/`** read the cleaned file and **must not** repeat these steps.

- **Raw input:** `data/Titanic-Dataset.csv`  
- **Cleaned output:** `data/titanic_cleaned.csv` (created by `clean_and_save_titanic.R`)

---

## What the cleaning does (in plain language)

The raw Titanic file is almost complete, but a few passengers are missing **age**, **embarkation port**, or have blank **embarked** codes. Many rows also lack **cabin**, which would block any analysis that needs a complete numeric or categorical vector for every passenger. The cleaning script has one main job: **prepare a single analytic table** where the variables your models and plots use are **complete and consistently coded**, without dropping passengers.

**Embarked.** Only a handful of rows omit the port. Rather than delete those passengers, we assign the **most common** embarkation code among everyone who *does* have a value. That keeps the full sample of 891 passengers and is a simple, transparent rule you can describe in your report.

**Age.** Missing ages are filled using **median imputation within each combination of class and sex** (for example, the median age of third-class males replaces missing ages for third-class males). Passengers who still lack an age after that step receive the **overall** median age. Medians are used instead of means so that a few very old or very young labelled passengers do not pull imputations away from a “typical” age in that group.

**Fare.** Fares are imputed the same way in spirit: **class median first**, then **global median** if anything remains missing. In this dataset fare is usually present; the rule still guarantees no missing fare in the output file.

**Variables we derive (not in the raw CSV).** We extract **Title** from **Name** so you can describe social role (Mr, Mrs, Miss, Master, etc.) without manual coding. **FamilySize** counts the passenger plus siblings/spouses and parents/children aboard; **IsSolo** flags people travelling alone. **Ticket_party_size** counts how many rows share the same **Ticket** (useful when one fare paid for several people); **Fare_per_person** divides total fare by that count so shared tickets are comparable to solo tickets. **SES_band** (**Low** / **Medium** / **High**) is an **ordinal proxy for relative spending within the same ticket class**: within each **Pclass**, passengers are ordered by **Fare_per_person** (ties broken by **PassengerId**), then split into three as-equal-as-possible groups. It is **not** annual income or a currency amount—only a transparent rule-based label for “lower vs higher fare share among peers in the same class.” **Deck** takes the first letter of **Cabin** when a cabin is recorded, and uses **U** (“unknown”) when cabin is missing, so you always have a deck-like field for plots and tables even though most cabin strings are empty.

**What we leave alone.** We do **not** invent cabin codes. **Cabin** in the CSV can still be blank; **Deck = U** tells you “no cabin on file.” **Survived**, **Pclass**, **Sex**, and **Embarked** are set to sensible types in R before export so downstream scripts treat class as ordered and categories as factors.

**Order and reproducibility.** Rows are sorted by **PassengerId** and written once to **`titanic_cleaned.csv`**. Anyone who runs `clean_and_save_titanic.R` from the project root gets the same file, which keeps your report and your group’s analysis aligned.

---

## Input

- **`data/Titanic-Dataset.csv`** — standard Titanic training-style file with columns such as `PassengerId`, `Survived`, `Pclass`, `Name`, `Sex`, `Age`, `SibSp`, `Parch`, `Ticket`, `Fare`, `Cabin`, `Embarked`.

---

## How to run

1. Open R and set the working directory to the **project root** (`MH3511`, the folder that contains `data/`).
2. Run:
   ```r
   source("data_cleaning/clean_and_save_titanic.R")
   ```
3. Confirm that **`data/titanic_cleaned.csv`** exists and has **891 rows**.

---

## What the script does (summary)

| Issue | Rule |
|--------|------|
| Missing **Embarked** | Filled with the **most common** port among non-missing rows. |
| Missing **Age** | **Median** within each **Pclass × Sex** group; any remaining with **global** median. |
| Missing **Fare** | **Median** within **Pclass**; any remaining with **global** median. |
| **Title** | Parsed from **`Name`** (text between `", "` and the first `.`). |
| **FamilySize** | `SibSp + Parch + 1`. |
| **IsSolo** | `1` if `FamilySize == 1`, else `0`. |
| **Ticket_party_size** | Number of passengers sharing the same **`Ticket`**. |
| **Fare_per_person** | `Fare / Ticket_party_size`. |
| **SES_band** | Within each **Pclass**, **Low** / **Medium** / **High** by **Fare_per_person** tertile groups (tie-break **PassengerId**); **not** literal income. |
| **Deck** | First character of **`Cabin`**; missing/empty cabin → **`U`** (Unknown). |
| **Types (in R before export)** | `Survived` integer 0/1; `Sex` / `Embarked` / ordered `Pclass` as factors in the cleaning script’s in-memory object. The CSV stores standard columns for interoperability. |

---

## Cleaned dataset output

This section documents the **file your group submits or cites** as the analytic dataset after cleaning.

### Output file

| Item | Detail |
|------|--------|
| **Path** | `data/titanic_cleaned.csv` |
| **Rows** | 891 (one per passenger; same as raw) |
| **Columns** | 19 |

### Column list (order in CSV)

| # | Column | Role |
|---|--------|------|
| 1 | `Ticket` | Ticket id (merge key for party size) |
| 2 | `PassengerId` | Passenger id |
| 3 | `Survived` | 0 = did not survive, 1 = survived |
| 4 | `Pclass` | 1 / 2 / 3 (first / second / third class) |
| 5 | `Name` | Full name |
| 6 | `Sex` | `male` / `female` |
| 7 | `Age` | Years (imputed; no missing) |
| 8 | `SibSp` | Siblings/spouses aboard |
| 9 | `Parch` | Parents/children aboard |
| 10 | `Fare` | Ticket fare (imputed; no missing) |
| 11 | `Cabin` | Cabin code (may still be empty in CSV; not imputed) |
| 12 | `Embarked` | `C` / `Q` / `S` (imputed; no missing) |
| 13 | `Title` | Derived from `Name` |
| 14 | `FamilySize` | `SibSp + Parch + 1` |
| 15 | `IsSolo` | 1 if travelling alone (`FamilySize == 1`), else 0 |
| 16 | `Ticket_party_size` | Count of passengers on same `Ticket` |
| 17 | `Fare_per_person` | `Fare / Ticket_party_size` |
| 18 | `SES_band` | Ordered **Low** < **Medium** < **High** (within-class **Fare_per_person** groups; not income) |
| 19 | `Deck` | First letter of cabin or `U` if unknown |

### Missingness: raw vs cleaned

Typical raw file (this project):

| Variable | Missing in **raw** (*n* = 891) | Missing in **`titanic_cleaned.csv`** |
|----------|--------------------------------|--------------------------------------|
| `Cabin` | 687 | Still absent as text (use **`Deck`**) |
| `Age` | 177 | **0** (imputed) |
| `Embarked` | 2 | **0** (imputed) |
| `Fare` | 0 | **0** |

### Sample of cleaned rows (first 8 passengers)

*Values taken from `titanic_cleaned.csv`; `Name` shortened for display.*

| PassengerId | Survived | Pclass | Sex | Age | Fare | Embarked | Title | FamilySize | IsSolo | Ticket_party_size | Fare_per_person | Deck |
|-------------|----------|--------|-----|-----|------|----------|-------|------------|--------|-------------------|-----------------|------|
| 1 | 0 | 3 | male | 22 | 7.25 | S | Mr | 2 | 0 | 1 | 7.25 | U |
| 2 | 1 | 1 | female | 38 | 71.2833 | C | Mrs | 2 | 0 | 1 | 71.2833 | C |
| 3 | 1 | 3 | female | 26 | 7.925 | S | Miss | 1 | 1 | 1 | 7.925 | U |
| 4 | 1 | 1 | female | 35 | 53.1 | S | Mrs | 2 | 0 | 2 | 26.55 | C |
| 5 | 0 | 3 | male | 35 | 8.05 | S | Mr | 1 | 1 | 1 | 8.05 | U |
| 6 | 0 | 3 | male | 25 | 8.4583 | Q | Mr | 1 | 1 | 1 | 8.4583 | U |
| 7 | 0 | 1 | male | 54 | 51.8625 | S | Mr | 1 | 1 | 1 | 51.8625 | E |
| 8 | 0 | 3 | male | 2 | 21.075 | S | Master | 5 | 0 | 4 | 5.26875 | U |

### Load in R (for appendix or extra tables)

```r
d <- read.csv("data/titanic_cleaned.csv", stringsAsFactors = FALSE)
str(d)
head(d, 20)
```

---

## Report alignment

- Use **§ “Cleaned dataset output”** above for the **data cleaning** chapter in Word (copy the tables).  
- The long-form report draft with figure callouts is **`REPORT_README.md`**.  
- If you change any cleaning rule, update **`clean_and_save_titanic.R`** and **this README** together, then re-run the script to regenerate **`titanic_cleaned.csv`**.
