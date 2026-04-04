# Section 4.4 — Train/test predictive performance (simple holdout)
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

set.seed(3511)
n <- nrow(d)
train_i <- sample.int(n, size = floor(0.8 * n))
train <- d[train_i, , drop = FALSE]
test <- d[-train_i, , drop = FALSE]

fit <- stats::glm(
  Survived ~ Pclass + Sex + Age + Fare,
  data = train,
  family = stats::binomial()
)
prob <- stats::predict(fit, newdata = test, type = "response")
pred <- as.integer(prob >= 0.5)

cm <- table(Actual = test$Survived, Predicted = pred)
print(cm)
acc <- mean(pred == test$Survived)
cat("Accuracy (0.5 threshold):", round(acc, 4), "\n")

if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  cmdf <- as.data.frame(cm)
  names(cmdf) <- c("Actual", "Predicted", "Freq")
  p <- ggplot2::ggplot(cmdf, ggplot2::aes(x = factor(Predicted), y = factor(Actual), fill = Freq)) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(ggplot2::aes(label = Freq), color = "white") +
    ggplot2::scale_fill_gradient(low = "gray30", high = "steelblue") +
    ggplot2::labs(title = "Confusion matrix (test set)", x = "Predicted", y = "Actual")
  ggplot2::ggsave(
    file.path(OUTPUT_FIG_DIR, "fig__sec04_04__confusion_matrix.png"),
    p, width = 5, height = 4, dpi = 150
  )
}
