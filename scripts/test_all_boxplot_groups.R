data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
plot_dir <- file.path("output", "boxplots")
report_path <- file.path("output", "boxplot_group_tests_report.txt")

if (!file.exists(data_path)) {
  stop("Missing processed dataset at: ", data_path, call. = FALSE)
}

coerce_numeric_like <- function(x) {
  if (is.logical(x)) {
    return(as.integer(x))
  }
  if (is.numeric(x) || is.integer(x)) {
    return(as.numeric(x))
  }
  y <- gsub("[$, ]", "", x)
  y[y == ""] <- NA
  suppressWarnings(as.numeric(y))
}

group_top_levels <- function(x, top_n, include_missing = TRUE) {
  valid <- !is.na(x) & x != ""
  counts <- sort(table(x[valid]), decreasing = TRUE)
  top_levels <- names(counts)[seq_len(min(top_n, length(counts)))]
  out <- ifelse(x %in% top_levels, x, "Other")
  if (include_missing) {
    out[is.na(x) | x == ""] <- "Missing"
  } else {
    out[is.na(x) | x == ""] <- NA_character_
  }
  out
}

quartile_band <- function(x, prefix) {
  x <- coerce_numeric_like(x)
  probs <- stats::quantile(x, probs = seq(0, 1, 0.25), na.rm = TRUE, type = 7)
  probs <- unique(probs)
  if (length(probs) < 3L) {
    return(rep(NA_character_, length(x)))
  }
  labels <- paste0(prefix, "_Q", seq_len(length(probs) - 1L))
  as.character(cut(x, breaks = probs, include.lowest = TRUE, labels = labels))
}

format_group_stat_lines <- function(named_values, digits = 6) {
  paste(names(named_values), sprintf(paste0("%.", digits, "f"), as.numeric(named_values)), sep = " = ")
}

run_group_test <- function(df, group_col, response_col, grouping_description, plot_file) {
  ok <- !is.na(df[[group_col]]) & df[[group_col]] != "" & !is.na(df[[response_col]])
  test_df <- df[ok, c(group_col, response_col)]
  names(test_df) <- c("grp", "y")
  test_df$grp <- factor(test_df$grp)

  group_counts <- sort(table(test_df$grp), decreasing = TRUE)
  group_means <- sort(tapply(test_df$y, test_df$grp, mean), decreasing = TRUE)
  group_variances <- tapply(test_df$y, test_df$grp, stats::var)
  ordered_group_variances <- setNames(
    as.numeric(group_variances[match(names(group_counts), names(group_variances))]),
    names(group_counts)
  )

  bartlett_result <- stats::bartlett.test(y ~ grp, data = test_df)
  fligner_result <- stats::fligner.test(y ~ grp, data = test_df)
  equal_variances <- fligner_result$p.value >= 0.05
  variance_choice <- "Fligner-Killeen test"

  if (nlevels(test_df$grp) == 2L) {
    if (equal_variances) {
      chosen_test <- "Student two-sample t-test"
      fit <- stats::t.test(y ~ grp, data = test_df, var.equal = TRUE)
    } else {
      chosen_test <- "Welch two-sample t-test"
      fit <- stats::t.test(y ~ grp, data = test_df, var.equal = FALSE)
    }
    statistic_value <- unname(fit$statistic)
    numerator_df <- NA_real_
    denominator_df <- unname(fit$parameter)
    p_value <- fit$p.value
    null_line <- "Null hypothesis: the two group means are equal."
  } else {
    if (equal_variances) {
      chosen_test <- "One-way ANOVA"
      fit <- stats::aov(y ~ grp, data = test_df)
      fit_table <- summary(fit)[[1]]
      statistic_value <- unname(fit_table$`F value`[1])
      numerator_df <- unname(fit_table$Df[1])
      denominator_df <- unname(fit_table$Df[2])
      p_value <- unname(fit_table$`Pr(>F)`[1])
    } else {
      chosen_test <- "Welch ANOVA"
      fit <- stats::oneway.test(y ~ grp, data = test_df, var.equal = FALSE)
      statistic_value <- unname(fit$statistic)
      numerator_df <- unname(fit$parameter[1])
      denominator_df <- unname(fit$parameter[2])
      p_value <- fit$p.value
    }
    null_line <- "Null hypothesis: all group means are equal."
  }

  decision_line <- if (p_value < 0.05) {
    "Decision: reject H0."
  } else {
    "Decision: fail to reject H0."
  }

  c(
    paste("Grouping:", group_col),
    paste("Grouping description:", grouping_description),
    paste("Related boxplot:", file.path(plot_dir, plot_file)),
    paste("Response variable:", response_col),
    paste("Rows used:", nrow(test_df)),
    paste("Groups used:", nlevels(test_df$grp)),
    "",
    "Group counts:",
    paste(names(group_counts), as.integer(group_counts), sep = " = "),
    "",
    "Group means:",
    format_group_stat_lines(group_means, digits = 6),
    "",
    "Group variances:",
    format_group_stat_lines(ordered_group_variances, digits = 6),
    "",
    "Equality-of-variance checks:",
    paste(
      "Bartlett test: K-squared =",
      sprintf("%.4f", unname(bartlett_result$statistic)),
      ", df =",
      unname(bartlett_result$parameter),
      ", p-value =",
      sprintf("%.6g", bartlett_result$p.value)
    ),
    paste(
      "Fligner-Killeen test: chi-squared =",
      sprintf("%.4f", unname(fligner_result$statistic)),
      ", df =",
      unname(fligner_result$parameter),
      ", p-value =",
      sprintf("%.6g", fligner_result$p.value)
    ),
    paste("Primary variance test used for decision:", variance_choice),
    paste("Equal variances assumed:", if (equal_variances) "Yes" else "No"),
    "",
    paste("Chosen mean-comparison test:", chosen_test),
    paste(
      "Test statistic =",
      sprintf("%.4f", statistic_value),
      if (is.na(numerator_df)) "" else paste0(", numerator df = ", sprintf("%.4f", numerator_df)),
      ", denominator df =",
      sprintf("%.4f", denominator_df),
      ", p-value =",
      sprintf("%.6g", p_value),
      sep = ""
    ),
    null_line,
    decision_line
  )
}

data <- utils::read.csv(data_path, stringsAsFactors = FALSE)
response_col <- if ("log_net_worth" %in% names(data)) {
  "log_net_worth"
} else {
  "log_log_net_worth"
}
data[[response_col]] <- coerce_numeric_like(data[[response_col]])

data$country_top10 <- group_top_levels(data$country, top_n = 10, include_missing = TRUE)
data$citizenship_top10 <- group_top_levels(data$countryOfCitizenship, top_n = 10, include_missing = FALSE)
data$title_top10 <- group_top_levels(data$title, top_n = 10, include_missing = FALSE)
data$birthYear_quartile <- quartile_band(data$birthYear, "BirthYear")
data$age_quartile <- quartile_band(data$age, "Age")

test_specs <- list(
  list(column = "status", description = "Raw status categories", plot_file = "status_boxplot.png"),
  list(column = "country_top10", description = "Top 10 countries + Other + Missing", plot_file = "country_top10_boxplot.png"),
  list(column = "citizenship_top10", description = "Top 10 countries of citizenship + Other", plot_file = "country_of_citizenship_top10_boxplot.png"),
  list(column = "title_top10", description = "Top 10 titles + Other", plot_file = "title_top10_boxplot.png"),
  list(column = "category", description = "Raw category field", plot_file = "category_boxplot.png"),
  list(column = "selfMade", description = "Binary selfMade field", plot_file = "selfMade_boxplot.png"),
  list(column = "birthYear_quartile", description = "Birth year split into quartiles", plot_file = "birthYear_quartile_boxplot.png"),
  list(column = "age_quartile", description = "Age split into quartiles", plot_file = "age_quartile_boxplot.png")
)

report_lines <- c(
  "Boxplot Group Mean Tests",
  paste("Response variable used across all tests:", response_col),
  "Variance decision rule: use Fligner-Killeen; if equal variances hold, use pooled t-test / one-way ANOVA; otherwise use Welch t-test / Welch ANOVA.",
  ""
)

for (spec in test_specs) {
  report_lines <- c(
    report_lines,
    paste(rep("=", 80), collapse = ""),
    run_group_test(
      df = data,
      group_col = spec$column,
      response_col = response_col,
      grouping_description = spec$description,
      plot_file = spec$plot_file
    ),
    ""
  )
}

writeLines(report_lines, report_path)
cat(paste(report_lines, collapse = "\n"), "\n")
cat("Report written to:", report_path, "\n")
