# Section 3.1 — Main outcome: Survived
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

tab <- prop.table(table(d$Survived))
print(round(tab, 4))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = factor(Survived, labels = c("Died", "Survived")))) +
    ggplot2::geom_bar(fill = "steelblue") +
    ggplot2::labs(title = "Passenger survival", x = NULL, y = "Count")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_01__survival_overall.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
