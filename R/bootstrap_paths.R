# Called from scripts via: source("R/bootstrap_paths.R") with working directory = project root (MH3511).

if (!dir.exists("data")) {
  stop(
    "Set R's working directory to the MH3511 project root (folder containing data/ and R/).",
    call. = FALSE
  )
}

MH3511_ROOT <- normalizePath(getwd(), winslash = "/")
DATA_CLEAN_CSV <- file.path(MH3511_ROOT, "data", "titanic_cleaned.csv")
OUTPUT_FIG_DIR <- file.path(MH3511_ROOT, "output", "figures")
dir.create(OUTPUT_FIG_DIR, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(DATA_CLEAN_CSV)) {
  stop(
    "Missing cleaned data. Run: source(\"data_cleaning/clean_and_save_titanic.R\")  (writes data/titanic_cleaned.csv)",
    call. = FALSE
  )
}

load_titanic_clean <- function() {
  x <- utils::read.csv(DATA_CLEAN_CSV, stringsAsFactors = FALSE)
  x$Pclass <- factor(x$Pclass, levels = c(1, 2, 3), ordered = TRUE)
  x$Sex <- factor(x$Sex, levels = c("male", "female"))
  x$Embarked <- factor(x$Embarked)
  x$Survived <- as.integer(x$Survived)
  x
}
