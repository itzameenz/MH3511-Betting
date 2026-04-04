# Section 3.2.4 — Fare and fare per person
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(summary(d$Fare))
print(summary(d$Fare_per_person))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p1 <- ggplot2::ggplot(d, ggplot2::aes(x = Fare)) +
    ggplot2::geom_histogram(bins = 40, fill = "darkseagreen", color = "white") +
    ggplot2::labs(title = "Fare distribution")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_04__fare_histogram.png"),
    p1, width = 6, height = 4, dpi = 150
  )
  p2 <- ggplot2::ggplot(d, ggplot2::aes(x = factor(Survived), y = Fare_per_person)) +
    ggplot2::geom_boxplot(outlier.alpha = 0.3) +
    ggplot2::labs(title = "Fare per person by survival", x = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_04__fare_per_person_boxplot.png"),
    p2, width = 5, height = 4, dpi = 150
  )
}
