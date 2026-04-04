# Explainer: `R/sec04_03__multivariable_logistic_regression_and_odds_ratios.R`

- **§4.3** — multivariable **logistic regression** (inference).
- **Model:** `Survived ~ Pclass + Sex + Age + Fare + Embarked`.
- **Prints:** `summary(glm)`; **OR** = `exp(coef)` with **95% CI**.
- **Figure:** forest-style OR ± CI (`geom_errorbar`, `orientation = "y"`; horizontal intervals).
