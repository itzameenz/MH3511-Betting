# Explainer: `data_cleaning/clean_and_save_titanic.R`

## Report section

This script is the **technical core of Section 3** (description and cleaning). Your **written narrative** for the marker should align with **`data_cleaning/README.md`**, especially the part **“What the cleaning does (in plain language).”** This explainer describes what the R file actually does line by line in words.

## In plain English

The raw Titanic CSV is almost complete, but some passengers are missing **age**, **embarked** port, or have blank port codes. The cleaning script reads that raw file once, applies **fixed, documented rules** (no analysis inside this file), and writes **`data/titanic_cleaned.csv`**. Every analysis script under **`R/`** is written to use **only** that cleaned file, so the whole group shares one definition of “the dataset.”

## Before you run

Set R’s working directory to the **project root** (the folder that contains **`data/`** and **`R/`**). The file **`data/Titanic-Dataset.csv`** must exist. If you run from the wrong folder, the script stops with an error telling you to use the MH3511 root.

## What the script does (walkthrough)

First it checks that it can see a **`data`** folder (or moves up one level if you accidentally ran from **`data_cleaning/`**). It reads the raw CSV with empty strings treated as missing. **Embarked** missing or blank values are replaced by the **most common** port among passengers who have a value, so you do not lose rows. **Age** is imputed using the **median age within each combination of passenger class and sex**; any age still missing after that gets the **global** median. **Fare** is imputed with **class medians**, then global median if needed. The script then **derives** new columns: **Title** from **Name**, **FamilySize** and **IsSolo**, **Ticket_party_size** (how many people share the same ticket string), **Fare_per_person**, **SES_band** (**Low** / **Medium** / **High** within each **Pclass** by sorting **Fare_per_person** and splitting into three groups—**not** income), and **Deck** from the first letter of **Cabin** (or **U** if cabin is unknown). Finally it sets sensible types (**Survived** as 0/1 integer, **Sex** and **Embarked** as factors, **Pclass** as ordered), sorts by **PassengerId**, and writes **`data/titanic_cleaned.csv`**.

## What you will see in the console

A short **message** with the number of rows (should be **891**) and the full path to the cleaned CSV. That message is normal; it is not an error.

## Figures

This script does **not** produce figures.

## For your report / interpretation

State clearly that imputation is **transparent** (median / mode rules) and that you are **not** claiming those imputed values are “true” ages or fares—only that they allow complete-case analysis. Mention that **cabin** can still be missing in the CSV while **Deck** uses **U** for unknown. If the marker asks for reproducibility, cite this script path and the output file name.
