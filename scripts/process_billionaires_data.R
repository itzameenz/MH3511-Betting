raw_path <- file.path("data", "raw", "Billionaires Statistics Dataset.csv")
clean_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
raw_hist_dir <- file.path("output", "histograms", "raw")
trans_hist_dir <- file.path("output", "histograms", "transformed")
skew_summary_path <- file.path("output", "skew_summary.csv")
correlation_path <- file.path("output", "correlation_to_net_worth.csv")
run_summary_path <- file.path("output", "run_summary.txt")

dir.create(dirname(clean_path), recursive = TRUE, showWarnings = FALSE)
dir.create(raw_hist_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(trans_hist_dir, recursive = TRUE, showWarnings = FALSE)

if (!file.exists(raw_path)) {
  stop("Missing raw dataset at: ", raw_path, call. = FALSE)
}

coerce_numeric_like <- function(x) {
  if (is.logical(x)) return(as.integer(x))
  if (is.numeric(x) || is.integer(x)) return(as.numeric(x))
  y <- gsub("[$, ]", "", x)
  y[y == ""] <- NA
  suppressWarnings(as.numeric(y))
}

skewness_value <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 3) return(NA_real_)
  sigma <- stats::sd(x)
  if (!is.finite(sigma) || sigma == 0) return(NA_real_)
  mu <- mean(x)
  mean(((x - mu) / sigma)^3)
}

log_transform <- function(x) {
  min_x <- min(x, na.rm = TRUE)
  shift <- if (min_x <= 0) abs(min_x) + 1 else 0
  log(x + shift)
}

exp_transform <- function(x) {
  rng <- range(x, na.rm = TRUE)
  if (!all(is.finite(rng)) || diff(rng) == 0) return(rep(NA_real_, length(x)))
  scaled <- (x - rng[1]) / diff(rng)
  exp(scaled)
}

best_secondary_right_skew_transform <- function(x) {
  candidates <- list(
    log = log_transform(x),
    sqrt = sqrt(x),
    cube_root = x^(1 / 3)
  )
  candidate_skews <- vapply(candidates, skewness_value, numeric(1))
  best_idx <- which.min(abs(candidate_skews))
  list(
    method = names(candidates)[best_idx],
    values = candidates[[best_idx]],
    skew = candidate_skews[[best_idx]]
  )
}

save_histogram <- function(x, column_name, out_dir) {
  x <- x[is.finite(x)]
  if (length(x) < 2) return(invisible(NULL))
  safe_name <- gsub("[^A-Za-z0-9_]+", "_", column_name)
  out_path <- file.path(out_dir, paste0(safe_name, ".png"))
  grDevices::png(out_path, width = 900, height = 600)
  graphics::hist(
    x,
    breaks = "FD",
    col = "#5B8FF9",
    border = "white",
    main = paste("Histogram:", column_name),
    xlab = column_name
  )
  grDevices::dev.off()
  invisible(out_path)
}

raw_data <- utils::read.csv(raw_path, stringsAsFactors = FALSE)

clean_data <- raw_data
names(clean_data)[names(clean_data) == "finalWorth"] <- "net_worth"
clean_data$selfMade_numeric <- as.integer(clean_data$selfMade)
clean_data$gdp_country_numeric <- coerce_numeric_like(clean_data$gdp_country)

analysis_numeric_cols <- c(
  "rank",
  "net_worth",
  "age",
  "selfMade_numeric",
  "birthYear",
  "birthMonth",
  "birthDay",
  "cpi_country",
  "cpi_change_country",
  "gdp_country_numeric",
  "gross_tertiary_education_enrollment",
  "gross_primary_education_enrollment_country",
  "life_expectancy_country",
  "tax_revenue_country_country",
  "total_tax_rate_country",
  "population_country",
  "latitude_country",
  "longitude_country"
)

for (col_name in analysis_numeric_cols) {
  save_histogram(coerce_numeric_like(clean_data[[col_name]]), col_name, raw_hist_dir)
}

skew_threshold <- 1
skew_summary <- data.frame(
  column = character(),
  raw_skew = numeric(),
  transform_method = character(),
  transformed_column = character(),
  transformed_skew = numeric(),
  transform_applied = logical(),
  stringsAsFactors = FALSE
)

transformed_cols <- character()

for (col_name in analysis_numeric_cols) {
  x <- coerce_numeric_like(clean_data[[col_name]])
  raw_skew <- skewness_value(x)
  method <- ""
  transformed_column <- ""
  transformed_skew <- NA_real_
  applied <- FALSE

  if (is.finite(raw_skew) && abs(raw_skew) > skew_threshold) {
    if (raw_skew > 0) {
      method <- "log"
      transformed_x <- log_transform(x)
    } else {
      method <- "exp"
      transformed_x <- exp_transform(x)
    }

    transformed_skew <- skewness_value(transformed_x)

    if (is.finite(transformed_skew) && abs(transformed_skew) < abs(raw_skew)) {
      transformed_column <- paste0(method, "_", col_name)
      clean_data[[transformed_column]] <- transformed_x
      transformed_cols <- c(transformed_cols, transformed_column)
      save_histogram(transformed_x, transformed_column, trans_hist_dir)
      applied <- TRUE
    }
  }

  skew_summary <- rbind(
    skew_summary,
    data.frame(
      column = col_name,
      raw_skew = raw_skew,
      transform_method = method,
      transformed_column = transformed_column,
      transformed_skew = transformed_skew,
      transform_applied = applied,
      stringsAsFactors = FALSE
    )
  )
}

if ("log_net_worth" %in% names(clean_data)) {
  x <- coerce_numeric_like(clean_data$log_net_worth)
  raw_skew <- skewness_value(x)
  method <- ""
  transformed_column <- ""
  transformed_skew <- NA_real_
  applied <- FALSE

  if (is.finite(raw_skew) && raw_skew > skew_threshold) {
    best_transform <- best_secondary_right_skew_transform(x)
    method <- best_transform$method
    transformed_skew <- best_transform$skew

    if (is.finite(transformed_skew) && abs(transformed_skew) < abs(raw_skew)) {
      transformed_column <- paste0(method, "_log_net_worth")
      clean_data[[transformed_column]] <- best_transform$values
      transformed_cols <- c(transformed_cols, transformed_column)
      save_histogram(best_transform$values, transformed_column, trans_hist_dir)
      applied <- TRUE
    }
  }

  skew_summary <- rbind(
    skew_summary,
    data.frame(
      column = "log_net_worth",
      raw_skew = raw_skew,
      transform_method = method,
      transformed_column = transformed_column,
      transformed_skew = transformed_skew,
      transform_applied = applied,
      stringsAsFactors = FALSE
    )
  )
}

correlation_cols <- unique(c(analysis_numeric_cols, transformed_cols))
correlation_cols <- setdiff(correlation_cols, "net_worth")

correlation_summary <- data.frame(
  column = correlation_cols,
  correlation_to_net_worth = vapply(
    correlation_cols,
    function(col_name) {
      x <- coerce_numeric_like(clean_data[[col_name]])
      stats::cor(x, clean_data$net_worth, use = "pairwise.complete.obs")
    },
    numeric(1)
  ),
  stringsAsFactors = FALSE
)

correlation_summary$abs_correlation <- abs(correlation_summary$correlation_to_net_worth)
correlation_summary <- correlation_summary[order(-correlation_summary$abs_correlation), ]
row.names(correlation_summary) <- NULL

utils::write.csv(clean_data, clean_path, row.names = FALSE, na = "")
utils::write.csv(skew_summary, skew_summary_path, row.names = FALSE, na = "")
utils::write.csv(correlation_summary, correlation_path, row.names = FALSE, na = "")

summary_lines <- c(
  paste("Rows:", nrow(clean_data)),
  paste("Columns:", ncol(clean_data)),
  paste("Raw numeric analysis columns:", length(analysis_numeric_cols)),
  paste("Transformed columns added:", length(transformed_cols)),
  paste("Transformed column names:", paste(transformed_cols, collapse = ", "))
)
writeLines(summary_lines, run_summary_path)

cat("Rows:", nrow(clean_data), "\n")
cat("Columns:", ncol(clean_data), "\n")
cat("Transformed columns added:", length(transformed_cols), "\n")
if (length(transformed_cols)) {
  cat("Added columns:", paste(transformed_cols, collapse = ", "), "\n")
}
