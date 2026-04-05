# Section 4.2.7 — SES_band vs survival (chi-squared)
# SES_band is a derived ordinal proxy; chi-squared treats it as categorical.
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

tab <- table(d$SES_band, d$Survived)
print(tab)
print(chisq.test(tab))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = SES_band, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "dodge") +
    ggplot2::labs(
      title = "Counts by SES_band and survival",
      x = "SES_band",
      fill = "Survived"
    )
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_07__ses_band_survival_counts.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
