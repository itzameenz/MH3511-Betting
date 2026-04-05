# Explainer: `R/sec04_03__multivariable_logistic_regression_and_odds_ratios.R`

## Report section

Supports **§4.3** — **multivariable logistic regression** and **odds ratios** with a **forest-style** plot.

## In plain English

A **logistic regression** models **log-odds** of survival as a **linear combination** of predictors. Here the formula is **Survived ~ Pclass + Sex + Age + Fare + Embarked**. **Pclass** is **ordered**, so R uses **polynomial contrasts** by default—you will see **Pclass.L** and **Pclass.Q** in **`summary`**, which are harder to read than raw “class 2 vs 1” dummies; for coursework you can still report **`summary`** and exponentiated **ORs** from **`coef`**. The script exponentiates coefficients and uses **`confint.default`** for **95% Wald intervals** (fast; **profile** CI is an alternative if taught). The plot shows **OR** and **CI** for each **term** except the intercept, with a vertical line at **OR = 1**.

## Before you run

Cleaned CSV; **ggplot2** for forest plot.

## What the script does (walkthrough)

**`glm(..., family = binomial)`**, **`summary`**, **`exp(coef)`**, **`exp(confint.default)`**, build a small table, filter out intercept, ggplot **point + geom_errorbar(orientation = "y")** for **xmin/xmax** = CI bounds.

## What you will see in the console

Coefficient table with **z** and **p**; **OR** table with **lo** and **hi**. Paste into **§4.3** and discuss **sign** and **magnitude**.

## Figures

- **`output/figures/fig__sec04_03__logistic_or_forest.png`**

## For your report / interpretation

Interpret **adjusted** associations (“holding other variables in the model constant” with usual linear-model caveats). **Fare** and **class** may **overlap**; a non-significant **Fare** OR here is plausible. **Sex** and **class** contrasts usually dominate. Mention **Wald** vs **profile** CI if your lecturer cares.
