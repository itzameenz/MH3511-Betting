install.packages(c("ggplot2", "dplyr", "forcats", "stringr", "broom"))

library(ggplot2)
library(dplyr)
library(forcats)
library(stringr)
library(broom)

df <- read.csv("C:\\Users\\siddh\\Downloads\\Billionaires Statistics Dataset.csv", stringsAsFactors = FALSE)

out_dir <- file.path(getwd(), "section_4_2_outputs")
if (!dir.exists(out_dir)) dir.create(out_dir)

df$log_net_worth <- log(df$finalWorth)
df$gdp_country_numeric <- as.numeric(gsub("[\\$, ]", "", df$gdp_country))
df$log_gdp_country <- log(df$gdp_country_numeric)

df$selfMade_label <- ifelse(df$selfMade %in% c(TRUE, "TRUE", "True", 1), "Self-made", "Not self-made")
df$selfMade_label <- factor(df$selfMade_label, levels = c("Not self-made", "Self-made"))

df$gender_label <- ifelse(df$gender == "M", "Male", ifelse(df$gender == "F", "Female", NA))
df$gender_label <- factor(df$gender_label, levels = c("Female", "Male"))

df$category <- as.factor(df$category)

df$country <- as.character(df$country)
top10_country <- names(sort(table(df$country), decreasing = TRUE)[1:10])
df$country_top10 <- ifelse(df$country %in% top10_country, df$country, "Other")
df$country_top10 <- factor(df$country_top10)

df$countryOfCitizenship <- as.character(df$countryOfCitizenship)
top10_citizenship <- names(sort(table(df$countryOfCitizenship), decreasing = TRUE)[1:10])
df$citizenship_top10 <- ifelse(df$countryOfCitizenship %in% top10_citizenship, df$countryOfCitizenship, "Other")
df$citizenship_top10 <- factor(df$citizenship_top10)

theme_custom <- function() {
  theme_gray(base_size = 13) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
      axis.title = element_text(face = "bold"),
      axis.text = element_text(size = 11),
      panel.grid.major = element_line(color = "grey80"),
      panel.grid.minor = element_line(color = "grey90")
    )
}

make_boxplot <- function(data, xvar, xlab, title, filename, horizontal = FALSE) {
  p <- ggplot(data, aes(x = .data[[xvar]], y = log_net_worth)) +
    geom_boxplot(fill = "grey85", color = "black", outlier.size = 0.9) +
    labs(title = title, x = xlab, y = "Log-transformed net worth") +
    theme_custom()
  
  if (horizontal) {
    p <- p + coord_flip()
  }
  
  ggsave(file.path(out_dir, filename), p, width = 10, height = 7, dpi = 300)
  print(p)
}

df_selfmade <- df %>% filter(!is.na(selfMade_label), !is.na(log_net_worth))
make_boxplot(
  df_selfmade,
  "selfMade_label",
  "Wealth origin group",
  "Log-transformed Net Worth by Wealth Origin",
  "section_4_2_1_wealth_origin_boxplot.png"
)
print(fligner.test(log_net_worth ~ selfMade_label, data = df_selfmade))
print(t.test(log_net_worth ~ selfMade_label, data = df_selfmade, var.equal = FALSE))

df_gender <- df %>% filter(!is.na(gender_label), !is.na(log_net_worth))
make_boxplot(
  df_gender,
  "gender_label",
  "Gender",
  "Log-transformed Net Worth by Gender",
  "section_4_2_2_gender_boxplot.png"
)
print(fligner.test(log_net_worth ~ gender_label, data = df_gender))
print(t.test(log_net_worth ~ gender_label, data = df_gender, var.equal = FALSE))

df_category <- df %>% filter(!is.na(category), !is.na(log_net_worth))
df_category$category_ordered <- fct_reorder(df_category$category, df_category$log_net_worth, median, na.rm = TRUE)
make_boxplot(
  df_category,
  "category_ordered",
  "Industry category",
  "Log-transformed Net Worth by Industry Category",
  "section_4_2_3_category_boxplot.png",
  TRUE
)
print(fligner.test(log_net_worth ~ category, data = df_category))
print(oneway.test(log_net_worth ~ category, data = df_category, var.equal = FALSE))

df_country <- df %>% filter(!is.na(country_top10), !is.na(log_net_worth))
df_country$country_top10_ordered <- fct_reorder(df_country$country_top10, df_country$log_net_worth, median, na.rm = TRUE)
make_boxplot(
  df_country,
  "country_top10_ordered",
  "Country of residence group",
  "Log-transformed Net Worth by Country of Residence (Top 10 + Other)",
  "section_4_2_4_country_boxplot.png",
  TRUE
)
print(fligner.test(log_net_worth ~ country_top10, data = df_country))
print(oneway.test(log_net_worth ~ country_top10, data = df_country, var.equal = FALSE))

df_citizenship <- df %>% filter(!is.na(citizenship_top10), !is.na(log_net_worth))
df_citizenship$citizenship_top10_ordered <- fct_reorder(df_citizenship$citizenship_top10, df_citizenship$log_net_worth, median, na.rm = TRUE)
make_boxplot(
  df_citizenship,
  "citizenship_top10_ordered",
  "Country of citizenship group",
  "Log-transformed Net Worth by Country of Citizenship (Top 10 + Other)",
  "section_4_2_5_citizenship_boxplot.png",
  TRUE
)
print(fligner.test(log_net_worth ~ citizenship_top10, data = df_citizenship))
print(oneway.test(log_net_worth ~ citizenship_top10, data = df_citizenship, var.equal = FALSE))

predictors <- c("age", "log_gdp_country", "cpi_country", "total_tax_rate_country")
model_list <- list()
summary_table <- data.frame(
  Predictor = character(),
  Fitted_Model = character(),
  P_Value = numeric(),
  R_Squared = numeric(),
  Adjusted_R_Squared = numeric(),
  stringsAsFactors = FALSE
)

for (var in predictors) {
  temp_df <- df %>% select(log_net_worth, all_of(var)) %>% na.omit()
  fit <- lm(as.formula(paste("log_net_worth ~", var)), data = temp_df)
  model_list[[var]] <- fit
  fit_sum <- summary(fit)
  
  summary_table <- rbind(
    summary_table,
    data.frame(
      Predictor = var,
      Fitted_Model = paste0(
        "log_net_worth = ",
        round(coef(fit)[1], 4),
        ifelse(coef(fit)[2] >= 0, " + ", " - "),
        abs(round(coef(fit)[2], 4)),
        " * ",
        var
      ),
      P_Value = coef(fit_sum)[2, 4],
      R_Squared = fit_sum$r.squared,
      Adjusted_R_Squared = fit_sum$adj.r.squared,
      stringsAsFactors = FALSE
    )
  )
}

print(summary_table)

for (var in predictors) {
  temp_df <- df %>% select(log_net_worth, all_of(var)) %>% na.omit()
  
  p <- ggplot(temp_df, aes(x = .data[[var]], y = log_net_worth)) +
    geom_point(alpha = 0.5, size = 1.3) +
    geom_smooth(method = "lm", se = FALSE, color = "black") +
    labs(
      title = paste("Log-transformed Net Worth versus", var),
      x = var,
      y = "Log-transformed net worth"
    ) +
    theme_custom()
  
  ggsave(file.path(out_dir, paste0("section_4_2_6_", var, "_scatter.png")), p, width = 8, height = 6, dpi = 300)
  print(p)
}

for (var in predictors) {
  temp_aug <- augment(model_list[[var]])
  
  p_qq <- ggplot(temp_aug, aes(sample = .std.resid)) +
    stat_qq(alpha = 0.5, size = 1.2) +
    stat_qq_line() +
    labs(
      title = paste("Q-Q Plot of Residuals:", var),
      x = "Theoretical quantiles",
      y = "Standardized residuals"
    ) +
    theme_custom()
  
  ggsave(file.path(out_dir, paste0("section_4_2_6_", var, "_qqplot.png")), p_qq, width = 8, height = 6, dpi = 300)
  print(p_qq)
}
