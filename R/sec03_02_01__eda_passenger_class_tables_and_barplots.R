# Section 3.2.1 — Pclass
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(table(d$Pclass))
print(prop.table(table(d$Pclass, d$Survived), margin = 1))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Pclass, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::labs(title = "Survival share by passenger class", x = "Pclass", y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_01__passenger_class_distribution.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
