# Section 3.2.6 — Embarked
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(table(d$Embarked))
print(prop.table(table(d$Embarked, d$Survived), margin = 1))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Embarked, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::labs(title = "Survival share by embarkation port", x = "Embarked", y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_06__embarked_survival.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
