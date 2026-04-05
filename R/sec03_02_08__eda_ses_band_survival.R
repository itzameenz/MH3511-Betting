# Section 3.2.8 — SES_band (within-class fare proxy) vs survival
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

print(table(Pclass = d$Pclass, SES_band = d$SES_band))
print(prop.table(table(d$SES_band, d$Survived), margin = 1))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = SES_band, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::facet_wrap(~Pclass, labeller = ggplot2::labeller(Pclass = function(x) paste("Class", x))) +
    ggplot2::labs(
      title = "Survival share by SES_band within passenger class",
      x = "SES_band (within-class fare tertile)",
      y = "Proportion",
      fill = "Survived"
    )
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec03_02_08__ses_band_survival_by_class.png"),
    p, width = 8, height = 4, dpi = 150
  )
}
