# Section 4.2.4 — Family size / solo vs survival
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

d$FamilySize_f <- factor(d$FamilySize)
tab_fs <- table(d$FamilySize_f, d$Survived)
print(chisq.test(tab_fs, simulate.p.value = TRUE, B = 10000))
print(chisq.test(table(d$IsSolo, d$Survived)))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  p <- ggplot2::ggplot(d, ggplot2::aes(x = factor(IsSolo, labels = c("Not solo", "Solo")), fill = factor(Survived))) +
    ggplot2::geom_bar(position = "fill") +
    ggplot2::labs(title = "Survival share: solo vs not", x = NULL, y = "Proportion", fill = "Survived")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_02_04__solo_survival.png"),
    p, width = 5, height = 4, dpi = 150
  )
}
