# Section 4.2.3 — Age vs survival
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

print(wilcox.test(Age ~ factor(Survived), data = d))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = factor(Survived), y = Age)) +
    ggplot2::geom_violin(fill = "lightblue", alpha = 0.6) +
    ggplot2::geom_boxplot(width = 0.15) +
    ggplot2::labs(title = "Age by survival", x = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_03__age_violin_survival.png"),
    p, width = 5, height = 4, dpi = 150
  )
}
