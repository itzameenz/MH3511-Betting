# Explainer: `R/sec04_02_03__statistical_tests_age_survivors_vs_nonsurvivors.R`

## Report section

Supports **§4.2.3** — **Age** vs survival.

## In plain English

Age distributions may differ between survivors and non-survivors, but normality is doubtful, so the script uses a **Wilcoxon rank-sum test** (same nonparametric family as **Mann–Whitney**). It answers whether one group tends to have **larger** ages than the other **without** assuming Gaussian errors. The **violin + boxplot** shows full shape plus quartiles.

## Before you run

Cleaned CSV; **ggplot2** for PNG.

## What the script does (walkthrough)

**`wilcox.test(Age ~ Survived)`** with default **continuity correction**. ggplot **violin** of **Age** by **Survived** with a narrow **boxplot** inside.

## What you will see in the console

**W** statistic and **p-value**. In this dataset the **p-value** is often **not** significant at 0.05 even though **§4.3** may show age significant in the **multivariable** model—be ready to explain **confounding** and **different question** (marginal vs adjusted).

## Figures

- **`output/figures/fig__sec04_02_03__age_violin_survival.png`**

## For your report / interpretation

Describe **Wilcoxon** as comparing **distributions** of age between groups. If **p** is large, say **no strong evidence** of a shift **marginally**; still discuss **adjusted** results in **§4.3**. If you use **imputed** ages, mention that as a limitation for strict inference.
