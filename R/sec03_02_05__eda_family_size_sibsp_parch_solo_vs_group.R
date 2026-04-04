# Section 3.2.5 — Family size / SibSp / Parch
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(summary(d[, c("SibSp", "Parch", "FamilySize", "IsSolo")]))
print(prop.table(table(d$IsSolo, d$Survived), margin = 1))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  d$FamilySize_f <- factor(d$FamilySize)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = FamilySize_f, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::labs(title = "Survival share by family size", x = "FamilySize", y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_05__family_size_survival.png"),
    p, width = 8, height = 4, dpi = 150
  )
}
