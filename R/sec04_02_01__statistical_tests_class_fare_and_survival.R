# Section 4.2.1 — Class, fare, survival
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

print(chisq.test(table(d$Pclass, d$Survived)))
print(wilcox.test(Fare ~ factor(Survived), data = d))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  # log10(0) is undefined; shift zero fares for display only (same count as raw zeros)
  eps <- min(d$Fare[d$Fare > 0], na.rm = TRUE) / 10
  d$Fare_log <- pmax(d$Fare, eps)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Pclass, y = Fare_log)) +
    ggplot2::geom_boxplot(outlier.alpha = 0.25) +
    ggplot2::facet_wrap(~ factor(Survived)) +
    ggplot2::scale_y_log10() +
    ggplot2::labs(
      title = "Fare by class and survival (log10 y)",
      x = "Pclass",
      y = "Fare (log10; 0 fares shown at min positive/10)"
    )
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_01__fare_by_class_survival.png"),
    p, width = 8, height = 4, dpi = 150
  )
}
