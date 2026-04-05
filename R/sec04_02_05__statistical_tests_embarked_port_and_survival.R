# Section 4.2.5 — Embarked vs survival
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

print(chisq.test(table(d$Embarked, d$Survived)))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Embarked, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "dodge") +
    ggplot2::labs(title = "Counts by embarkation and survival", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_05__embarked_counts.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
