# Section 4.3 — Multivariable logistic regression (inference / ORs)
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

fit <- stats::glm(
  Survived ~ Pclass + Sex + Age + Fare + Embarked,
  data = d,
  family = stats::binomial()
)
print(summary(fit))

or <- exp(stats::coef(fit))
ci <- exp(stats::confint.default(fit))
or_tab <- cbind(OR = or, lo = ci[, 1L], hi = ci[, 2L])
print(round(or_tab, 4))

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  td <- as.data.frame(or_tab)
  td$term <- rownames(td)
  td <- td[td$term != "(Intercept)", , drop = FALSE]
  p <- ggplot2::ggplot(td, ggplot2::aes(x = OR, y = stats::reorder(term, OR))) +
    ggplot2::geom_point() +
    ggplot2::geom_errorbar(
      ggplot2::aes(xmin = lo, xmax = hi),
      orientation = "y",
      width = 0.2
    ) +
    ggplot2::geom_vline(xintercept = 1, linetype = 2) +
    ggplot2::labs(title = "Odds ratios (multivariable glm)", x = "OR", y = NULL)
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_03__logistic_or_forest.png"),
    p, width = 7, height = 4, dpi = 150
  )
}
