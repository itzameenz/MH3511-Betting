# Run from project root (MH3511). Cleans data, then runs every sec*.R in lexical order.
# Excludes bootstrap_paths.R.

if (!dir.exists("data")) stop("Set working directory to MH3511 project root.")

source("data_cleaning/clean_and_save_titanic.R")

sec_scripts <- sort(list.files(
  path = "R",
  pattern = "^sec[0-9].*\\.R$",
  full.names = TRUE
))
for (path in sec_scripts) {
  message("--- Sourcing ", path, " ---")
  source(path, encoding = "UTF-8")
}

message("Done. Figures in output/figures/")
