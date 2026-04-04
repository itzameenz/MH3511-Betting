# Explainer: `data_cleaning/clean_and_save_titanic.R`

## Report section
Section **3 (Description and cleaning)** — technical side; narrative is in `data_cleaning/README.md`.

## Prerequisites
- Working directory = **MH3511** project root.
- **`data/Titanic-Dataset.csv`** present.

## Outputs
- **`data/titanic_cleaned.csv`**
- Console message with row count and path to `data/titanic_cleaned.csv`.

## What the code does (steps)
1. **`ensure_project_root()`** — stops if `data/` is not visible (wrong working directory).
2. **Read** raw CSV.
3. **Embarked** — fill missing with mode.
4. **Age** — median within each **Pclass × Sex**, then global median.
5. **Fare** — median within **Pclass**, then global median.
6. **Title** — regex on **`Name`**.
7. **FamilySize**, **IsSolo**, **Ticket_party_size**, **Fare_per_person**, **Deck**.
8. **Sort** by `PassengerId`, **write** cleaned CSV.

## How to interpret
After running, you should have **no missing Age/Fare/Embarked** in the cleaned file (check with `summary()` in R).
