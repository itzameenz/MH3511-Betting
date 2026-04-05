# Section 3.2.2 — Sex
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
print(table(d$Sex))
print(prop.table(table(d$Sex, d$Survived), margin = 1))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Sex, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::labs(title = "Survival share by sex", x = NULL, y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_02__sex_survival_share.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
