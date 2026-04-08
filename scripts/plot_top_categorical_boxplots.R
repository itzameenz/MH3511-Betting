data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
plot_dir <- file.path("output", "boxplots")

dir.create(plot_dir, recursive = TRUE, showWarnings = FALSE)

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

group_top_levels <- function(x, top_n, include_missing = TRUE) {
  counts <- sort(table(x), decreasing = TRUE)
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

plot_boxplot <- function(df, group_col, y_col, title_text, file_name) {
  ok <- !is.na(df[[group_col]]) & df[[group_col]] != "" & !is.na(df[[y_col]])
  plot_df <- df[ok, c(group_col, y_col)]
  names(plot_df) <- c("grp", "y")

  group_means <- tapply(plot_df$y, plot_df$grp, mean)
  ordered_levels <- names(sort(group_means, decreasing = TRUE))
  plot_df$grp <- factor(plot_df$grp, levels = ordered_levels)

  out_path <- file.path(plot_dir, file_name)
  grDevices::png(out_path, width = 1600, height = 900, res = 140)
  graphics::par(mar = c(10, 5, 4, 2) + 0.1)
  graphics::boxplot(
    y ~ grp,
    data = plot_df,
    las = 2,
    col = "#9EC1A3",
    border = "#2F5D50",
    main = title_text,
    xlab = "",
    ylab = y_col,
    cex.axis = 0.9,
    outline = TRUE
  )
  graphics::grid(nx = NA, ny = NULL, col = "#DDDDDD", lty = "dotted")
  grDevices::dev.off()

  invisible(out_path)
}

data <- utils::read.csv(data_path, stringsAsFactors = FALSE)

response_col <- if ("log_log_net_worth" %in% names(data)) {
  "log_log_net_worth"
} else {
  "log_net_worth"
}
data[[response_col]] <- coerce_numeric_like(data[[response_col]])

data$country_top10 <- group_top_levels(data$country, top_n = 10, include_missing = TRUE)
data$citizenship_top10 <- group_top_levels(data$countryOfCitizenship, top_n = 10, include_missing = FALSE)
data$birthYear_quartile <- quartile_band(data$birthYear, "BirthYear")
data$age_quartile <- quartile_band(data$age, "Age")

plot_specs <- list(
  list(column = "status", title = paste("Boxplot of", response_col, "by status"), file = "status_boxplot.png"),
  list(column = "country_top10", title = paste("Boxplot of", response_col, "by country (Top 10 + Other + Missing)"), file = "country_top10_boxplot.png"),
  list(column = "citizenship_top10", title = paste("Boxplot of", response_col, "by country of citizenship (Top 10 + Other)"), file = "country_of_citizenship_top10_boxplot.png"),
  list(column = "category", title = paste("Boxplot of", response_col, "by category"), file = "category_boxplot.png"),
  list(column = "selfMade", title = paste("Boxplot of", response_col, "by selfMade"), file = "selfMade_boxplot.png"),
  list(column = "birthYear_quartile", title = paste("Boxplot of", response_col, "by birthYear quartile"), file = "birthYear_quartile_boxplot.png"),
  list(column = "age_quartile", title = paste("Boxplot of", response_col, "by age quartile"), file = "age_quartile_boxplot.png")
)

for (spec in plot_specs) {
  plot_boxplot(
    df = data,
    group_col = spec$column,
    y_col = response_col,
    title_text = spec$title,
    file_name = spec$file
  )
}

cat("Saved boxplots to:", plot_dir, "\n")
cat("Response used:", response_col, "\n")
