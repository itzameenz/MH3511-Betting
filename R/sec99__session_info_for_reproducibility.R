# Appendix — reproducibility
source("R/bootstrap_paths.R")
cat("Clean data file:", DATA_CLEAN_CSV, "\n")
cat("Figure output dir:", OUTPUT_FIG_DIR, "\n\n")
print(utils::sessionInfo())
