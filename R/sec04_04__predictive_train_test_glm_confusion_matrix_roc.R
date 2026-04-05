# Section 4.4 — Train/test predictive performance (stratified 80/20 holdout)
# Preserves approximate outcome prevalence in train and test (Survived 0 vs 1).
source("R/bootstrap_paths.R")
d <- load_titanic_clean()

set.seed(3511)
idx0 <- which(d$Survived == 0L)
idx1 <- which(d$Survived == 1L)
n_train_0 <- floor(0.8 * length(idx0))
n_train_1 <- floor(0.8 * length(idx1))
train_i <- c(
  sample(idx0, n_train_0),
  sample(idx1, n_train_1)
)
train <- d[train_i, , drop = FALSE]
test <- d[-train_i, , drop = FALSE]
cat(
  "Train survival rate:", round(mean(train$Survived), 4),
  "| Test survival rate:", round(mean(test$Survived), 4), "\n"
)

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
tp <- sum(test$Survived == 1L & pred == 1L)
fn <- sum(test$Survived == 1L & pred == 0L)
tn <- sum(test$Survived == 0L & pred == 0L)
fp <- sum(test$Survived == 0L & pred == 1L)
sens <- if (tp + fn > 0L) tp / (tp + fn) else NA_real_
spec <- if (tn + fp > 0L) tn / (tn + fp) else NA_real_
cat("Sensitivity (recall, actual survived):", round(sens, 4), "\n")
cat("Specificity (actual not survived):", round(spec, 4), "\n")

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
