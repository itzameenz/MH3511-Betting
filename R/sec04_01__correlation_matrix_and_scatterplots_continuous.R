# Section 4.1 — Correlations among numeric variables
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
num_cols <- c("Age", "Fare", "SibSp", "Parch", "FamilySize", "Fare_per_person", "Ticket_party_size", "Survived")
num <- d[, intersect(num_cols, names(d)), drop = FALSE]
print(round(cor(num, use = "complete.obs"), 3))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Age, y = Fare, color = factor(Survived))) +
    ggplot2::geom_point(alpha = 0.35) +
    ggplot2::labs(title = "Fare vs Age by survival", color = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_01__scatter_age_fare_survival.png"),
    p, width = 7, height = 5, dpi = 150
  )
}
