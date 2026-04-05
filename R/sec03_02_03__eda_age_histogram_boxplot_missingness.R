# Section 3.2.3 — Age (post-cleaning; no NAs expected)
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(summary(d$Age))
cat("NA count Age:", sum(is.na(d$Age)), "\n")

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p1 <- ggplot2::ggplot(d, ggplot2::aes(x = Age)) +
    ggplot2::geom_histogram(bins = 30, fill = "gray60", color = "white") +
    ggplot2::facet_wrap(~ factor(Survived)) +
    ggplot2::labs(title = "Age distribution by survival")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_03__age_histogram_by_survival.png"),
    p1, width = 8, height = 4, dpi = 150
  )
  p2 <- ggplot2::ggplot(d, ggplot2::aes(x = factor(Survived), y = Age)) +
    ggplot2::geom_boxplot() +
    ggplot2::labs(title = "Age by survival", x = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_03__age_boxplot_by_survival.png"),
    p2, width = 5, height = 4, dpi = 150
  )
}
