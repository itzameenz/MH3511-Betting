data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
cat_out_path <- file.path("output", "recommended_categorical_analysis.csv")
cont_out_path <- file.path("output", "recommended_continuous_analysis.csv")
overall_out_path <- file.path("output", "recommended_factor_strength.csv")

if (!file.exists(data_path)) {
  stop("Missing processed dataset at: ", data_path, call. = FALSE)
}

coerce_numeric_like <- function(x) {
  if (is.logical(x)) return(as.integer(x))
  if (is.numeric(x) || is.integer(x)) return(as.numeric(x))
  y <- gsub("[$, ]", "", x)
  y[y == ""] <- NA
  suppressWarnings(as.numeric(y))
}

anova_eta_squared <- function(y, grp) {
  fit <- stats::aov(y ~ grp)
  tab <- summary(fit)[[1]]
  ss_between <- tab$`Sum Sq`[1]
  ss_total <- sum(tab$`Sum Sq`, na.rm = TRUE)
  ss_between / ss_total
}

group_top_levels <- function(x, top_n, include_missing = TRUE) {
  counts <- sort(table(x), decreasing = TRUE)
  top_levels <- names(counts)[seq_len(min(top_n, length(counts)))]
  out <- ifelse(x %in% top_levels, x, "Other")
  if (include_missing) {
    out[is.na(x) | x == ""] <- "Missing"
  }
  out
}

data <- utils::read.csv(data_path, stringsAsFactors = FALSE)
data$log_net_worth <- coerce_numeric_like(data$log_net_worth)
data$birthYear <- coerce_numeric_like(data$birthYear)

data$country_group <- group_top_levels(data$country, top_n = 10, include_missing = TRUE)
data$citizenship_group <- group_top_levels(data$countryOfCitizenship, top_n = 10, include_missing = FALSE)

categorical_specs <- list(
  list(column = "category", label = "category"),
  list(column = "country_group", label = "country"),
  list(column = "citizenship_group", label = "countryOfCitizenship"),
  list(column = "selfMade", label = "selfMade"),
  list(column = "gender", label = "gender"),
  list(column = "status", label = "status")
)

categorical_results <- data.frame(
  variable = character(),
  test = character(),
  n = integer(),
  groups = integer(),
  statistic = numeric(),
  numerator_df = numeric(),
  denominator_df = numeric(),
  p_value = numeric(),
  variance_explained = numeric(),
  highest_group = character(),
  highest_group_mean_log_net_worth = numeric(),
  stringsAsFactors = FALSE
)

for (spec in categorical_specs) {
  ok <- !is.na(data[[spec$column]]) & data[[spec$column]] != "" & !is.na(data$log_net_worth)
  df <- data[ok, c(spec$column, "log_net_worth")]
  names(df) <- c("grp", "y")
  df$grp <- as.factor(df$grp)

  fit <- stats::oneway.test(y ~ grp, data = df, var.equal = FALSE)
  means <- sort(tapply(df$y, df$grp, mean), decreasing = TRUE)
  test_name <- if (nlevels(df$grp) == 2L) "Welch t-test equivalent" else "Welch ANOVA"

  categorical_results <- rbind(
    categorical_results,
    data.frame(
      variable = spec$label,
      test = test_name,
      n = nrow(df),
      groups = nlevels(df$grp),
      statistic = unname(fit$statistic),
      numerator_df = unname(fit$parameter[1]),
      denominator_df = if (length(fit$parameter) > 1L) unname(fit$parameter[2]) else NA_real_,
      p_value = fit$p.value,
      variance_explained = anova_eta_squared(df$y, df$grp),
      highest_group = names(means)[1],
      highest_group_mean_log_net_worth = unname(means[1]),
      stringsAsFactors = FALSE
    )
  )
}

continuous_results <- data.frame(
  variable = "birthYear",
  test = "Pearson correlation + simple linear regression",
  n = NA_integer_,
  correlation_with_log_net_worth = NA_real_,
  slope = NA_real_,
  p_value = NA_real_,
  variance_explained = NA_real_,
  stringsAsFactors = FALSE
)

ok_birth <- !is.na(data$birthYear) & !is.na(data$log_net_worth)
birth_df <- data.frame(x = data$birthYear[ok_birth], y = data$log_net_worth[ok_birth])
birth_fit <- stats::lm(y ~ x, data = birth_df)
birth_sum <- summary(birth_fit)

continuous_results$n <- nrow(birth_df)
continuous_results$correlation_with_log_net_worth <- stats::cor(birth_df$x, birth_df$y)
continuous_results$slope <- unname(stats::coef(birth_fit)[2])
continuous_results$p_value <- unname(birth_sum$coefficients[2, 4])
continuous_results$variance_explained <- unname(birth_sum$r.squared)

overall_results <- rbind(
  data.frame(
    variable = categorical_results$variable,
    family = "categorical",
    variance_explained = categorical_results$variance_explained,
    p_value = categorical_results$p_value,
    stringsAsFactors = FALSE
  ),
  data.frame(
    variable = continuous_results$variable,
    family = "continuous",
    variance_explained = continuous_results$variance_explained,
    p_value = continuous_results$p_value,
    stringsAsFactors = FALSE
  )
)
overall_results <- overall_results[order(-overall_results$variance_explained), ]
row.names(overall_results) <- NULL

utils::write.csv(categorical_results, cat_out_path, row.names = FALSE, na = "")
utils::write.csv(continuous_results, cont_out_path, row.names = FALSE, na = "")
utils::write.csv(overall_results, overall_out_path, row.names = FALSE, na = "")

cat("Recommended categorical analyses written to:", cat_out_path, "\n")
cat("Recommended continuous analyses written to:", cont_out_path, "\n")
cat("Recommended factor ranking written to:", overall_out_path, "\n")
