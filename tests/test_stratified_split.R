# Stratified 80/20 train/test logic (mirrors R/sec04_04__...).
# Run from project root: Rscript tests/test_stratified_split.R

stopifnot(dir.exists("data"), file.exists("data/titanic_cleaned.csv"))

source("R/bootstrap_paths.R")
d <- load_titanic_clean()

set.seed(3511)
idx0 <- which(d$Survived == 0L)
idx1 <- which(d$Survived == 1L)
n_train_0 <- floor(0.8 * length(idx0))
n_train_1 <- floor(0.8 * length(idx1))
train_i <- c(sample(idx0, n_train_0), sample(idx1, n_train_1))
train <- d[train_i, , drop = FALSE]
test <- d[-train_i, , drop = FALSE]

stopifnot(nrow(train) + nrow(test) == nrow(d))
stopifnot(nrow(train) == n_train_0 + n_train_1)
# Stratified split keeps outcome prevalence similar in train and test
stopifnot(abs(mean(train$Survived) - mean(test$Survived)) < 0.05)

message("test_stratified_split.R: OK")
