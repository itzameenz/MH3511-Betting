# Section 3.3 — Final analytic dataset summary
source("R/bootstrap_paths.R")
d <- load_titanic_clean()
cat("Rows:", nrow(d), "  Columns:", ncol(d), "\n")
print(names(d))
utils::str(d, vec.len = 2)
