data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
cat_out_path <- file.path("output", "categorical_final_worth_analysis.csv")
cont_out_path <- file.path("output", "continuous_final_worth_analysis.csv")
overall_out_path <- file.path("output", "overall_factor_strength.csv")

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

anova_eta_squared <- function(fit) {
  tab <- summary(fit)[[1]]
  ss_between <- tab$`Sum Sq`[1]
  ss_total <- sum(tab$`Sum Sq`, na.rm = TRUE)
  ss_between / ss_total
}

data <- utils::read.csv(data_path, stringsAsFactors = FALSE)
data$log_net_worth <- coerce_numeric_like(data$log_net_worth)
data$final_worth <- coerce_numeric_like(data$net_worth)

state_counts <- sort(table(data$state), decreasing = TRUE)
top_states <- names(state_counts)[1:10]
data$state_group <- ifelse(
  is.na(data$state) | data$state == "",
  "Missing",
  ifelse(data$state %in% top_states, data$state, "Other")
)

categorical_specs <- list(
  list(column = "category", label = "category"),
  list(column = "state_group", label = "state"),
  list(column = "industries", label = "industries"),
  list(column = "selfMade", label = "selfMade")
)

categorical_results <- data.frame(
  variable = character(),
  test = character(),
  n = integer(),
  groups = integer(),
  statistic = numeric(),
  p_value = numeric(),
  variance_explained = numeric(),
  highest_group = character(),
  highest_group_mean_log_final_worth = numeric(),
  stringsAsFactors = FALSE
)

for (spec in categorical_specs) {
  ok <- !is.na(data[[spec$column]]) & data[[spec$column]] != "" & !is.na(data$log_net_worth)
  df <- data[ok, c(spec$column, "log_net_worth")]
  names(df) <- c("grp", "y")
  df$grp <- as.factor(df$grp)

  fit <- stats::aov(y ~ grp, data = df)
  tab <- summary(fit)[[1]]
  means <- sort(tapply(df$y, df$grp, mean), decreasing = TRUE)
  test_name <- if (nlevels(df$grp) == 2L) "t-test equivalent (2-level ANOVA)" else "one-way ANOVA"

  categorical_results <- rbind(
    categorical_results,
    data.frame(
      variable = spec$label,
      test = test_name,
      n = nrow(df),
      groups = nlevels(df$grp),
      statistic = unname(tab$`F value`[1]),
      p_value = unname(tab$`Pr(>F)`[1]),
      variance_explained = anova_eta_squared(fit),
      highest_group = names(means)[1],
      highest_group_mean_log_final_worth = unname(means[1]),
      stringsAsFactors = FALSE
    )
  )
}

continuous_specs <- list(
  list(column = "cpi_country", label = "cpi_country"),
  list(column = "gdp_country_numeric", label = "gdp_country"),
  list(column = "gross_tertiary_education_enrollment", label = "tertiary_edu"),
  list(column = "cpi_change_country", label = "cpi_change_country"),
  list(column = "life_expectancy_country", label = "life_expectancy")
)

continuous_results <- data.frame(
  variable = character(),
  test = character(),
  n = integer(),
  correlation_with_log_final_worth = numeric(),
  slope = numeric(),
  p_value = numeric(),
  variance_explained = numeric(),
  stringsAsFactors = FALSE
)

for (spec in continuous_specs) {
  x <- coerce_numeric_like(data[[spec$column]])
  ok <- !is.na(x) & !is.na(data$log_net_worth)
  df <- data.frame(x = x[ok], y = data$log_net_worth[ok])
  fit <- stats::lm(y ~ x, data = df)
  fit_sum <- summary(fit)

  continuous_results <- rbind(
    continuous_results,
    data.frame(
      variable = spec$label,
      test = "Pearson correlation + simple linear regression",
      n = nrow(df),
      correlation_with_log_final_worth = stats::cor(df$x, df$y),
      slope = unname(stats::coef(fit)[2]),
      p_value = unname(fit_sum$coefficients[2, 4]),
      variance_explained = unname(fit_sum$r.squared),
      stringsAsFactors = FALSE
    )
  )
}

overall_results <- rbind(
  data.frame(
    variable = categorical_results$variable,
    family = "categorical",
    variance_explained = categorical_results$variance_explained,
    stringsAsFactors = FALSE
  ),
  data.frame(
    variable = continuous_results$variable,
    family = "continuous",
    variance_explained = continuous_results$variance_explained,
    stringsAsFactors = FALSE
  )
)
overall_results <- overall_results[order(-overall_results$variance_explained), ]
row.names(overall_results) <- NULL

utils::write.csv(categorical_results, cat_out_path, row.names = FALSE, na = "")
utils::write.csv(continuous_results, cont_out_path, row.names = FALSE, na = "")
utils::write.csv(overall_results, overall_out_path, row.names = FALSE, na = "")

cat("Categorical analyses written to:", cat_out_path, "\n")
cat("Continuous analyses written to:", cont_out_path, "\n")
cat("Overall ranking written to:", overall_out_path, "\n")
