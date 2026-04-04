# Section 4.2.2 — Sex, survival, survivor composition
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

print(chisq.test(table(d$Sex, d$Survived)))

surv <- d$Survived == 1
male_share <- mean(d$Sex[surv] == "male")
cat("Among survivors: proportion male =", round(male_share, 4), "\n")
print(stats::binom.test(sum(d$Sex[surv] == "male"), sum(surv)))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = Sex, fill = factor(Survived))) +
    ggplot2::geom_bar(position = "dodge") +
    ggplot2::labs(title = "Counts by sex and survival", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_02__sex_survival_counts.png"),
    p, width = 6, height = 4, dpi = 150
  )
}
