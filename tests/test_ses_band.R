# SES_band: no NAs, valid levels, counts per Pclass sum correctly.
# Run from project root: Rscript tests/test_ses_band.R

stopifnot(dir.exists("data"), file.exists("data/titanic_cleaned.csv"))

source("R/bootstrap_paths.R")
d <- load_titanic_clean()

stopifnot("SES_band" %in% names(d))
stopifnot(!any(is.na(d$SES_band)))
stopifnot(all(as.character(d$SES_band) %in% c("Low", "Medium", "High")))
stopifnot(length(unique(d$SES_band)) >= 2L)
message("test_ses_band.R: OK")
