install.packages(c("dplyr", "broom", "car"))

library(dplyr)
library(broom)
library(car)

# 1. LOAD DATA
df <- read.csv(
  "C:\\Users\\siddh\\Downloads\\Billionaires Statistics Dataset.csv",
  stringsAsFactors = FALSE
)

# 2. PREPARE VARIABLES
df$log_net_worth <- log(df$finalWorth)

df$gdp_country_numeric <- as.numeric(gsub("[\\$, ]", "", df$gdp_country))
df$log_gdp_country <- log(df$gdp_country_numeric)

df$selfMade_label <- ifelse(df$selfMade %in% c(TRUE, "TRUE", "True", 1),
                            "Self-made", "Not self-made")
df$selfMade_label <- factor(df$selfMade_label,
                            levels = c("Not self-made", "Self-made"))

df$gender_label <- ifelse(df$gender == "M", "Male",
                          ifelse(df$gender == "F", "Female", NA))
df$gender_label <- factor(df$gender_label,
                          levels = c("Female", "Male"))

df$category <- as.factor(df$category)

df$country <- as.character(df$country)
top10_country <- names(sort(table(df$country), decreasing = TRUE)[1:10])
df$country_top10 <- ifelse(df$country %in% top10_country, df$country, "Other")
df$country_top10 <- factor(df$country_top10)

# Set reference levels explicitly
df$category <- relevel(df$category, ref = levels(df$category)[1])
df$country_top10 <- relevel(df$country_top10, ref = "Other")

# 3. CREATE MODELLING DATASET
model_df <- df %>%
  select(
    log_net_worth,
    age,
    selfMade_label,
    gender_label,
    category,
    country_top10,
    log_gdp_country,
    cpi_country,
    total_tax_rate_country
  ) %>%
  na.omit()

# 4. FIT FULL MODEL
model_full <- lm(
  log_net_worth ~ age + selfMade_label + gender_label +
    category + country_top10 + log_gdp_country +
    cpi_country + total_tax_rate_country,
  data = model_df
)

cat("\n============================\n")
cat("FULL MODEL SUMMARY\n")
cat("============================\n")
print(summary(model_full))

# 5. BACKWARD ELIMINATION
cat("BACKWARD ELIMINATION OUTPUT\n")
model_final <- step(model_full, direction = "backward")

# 6. FINAL MODEL SUMMARY
cat("FINAL MODEL SUMMARY\n")
final_summary <- summary(model_final)
print(final_summary)

# 7. COMPACT OUTPUTS FOR REPORT

# coefficient table
coef_table <- tidy(model_final, conf.int = TRUE)

write.csv(coef_table, "section_4_3_all_coefficients.csv", row.names = FALSE)

# Statistically significant coefficients (p < 0.05)
sig_coef_table <- coef_table %>%
  filter(term != "(Intercept)", p.value < 0.05)

write.csv(sig_coef_table, "section_4_3_significant_coefficients.csv", row.names = FALSE)

cat("SIGNIFICANT COEFFICIENTS (p < 0.05)\n")
print(sig_coef_table)

# 8. MODEL FIT STATISTICS
model_fit <- glance(model_final)

cat("MODEL FIT STATISTICS\n")
print(model_fit)

# 9. ANOVA TABLE
cat("ANOVA TABLE FOR FINAL MODEL\n")
anova_table <- anova(model_final)
print(anova_table)
write.csv(as.data.frame(anova_table), "section_4_3_anova_table.csv")

# 10. VIF CHECK
cat("VIF VALUES\n")
vif_values <- vif(model_final)
print(vif_values)

vif_df <- as.data.frame(vif_values)
vif_df$Predictor <- rownames(vif_df)
write.csv(vif_df, "section_4_3_vif_values.csv", row.names = FALSE)

# 11. CLEAN EQUATION COMPONENTS FOR REPORT
coefs <- coef(model_final)

cat("COMPACT EQUATION FOR MAIN REPORT\n")

cat(
  "log(Net Worth) = ",
  round(coefs["(Intercept)"], 4),
  " + ",
  round(coefs["age"], 4), "*(Age)",
  " + ",
  round(coefs["selfMade_labelSelf-made"], 4), "*(Self-made)",
  " + ",
  round(coefs["cpi_country"], 4), "*(CPI)",
  " + Category effects + Country effects\n",
  sep = ""
)

# 12. REFERENCE GROUPS
cat("REFERENCE GROUPS\n")
cat("Reference wealth origin group:", levels(model_df$selfMade_label)[1], "\n")
cat("Reference gender group:", levels(model_df$gender_label)[1], "\n")
cat("Reference category group:", levels(model_df$category)[1], "\n")
cat("Reference country group:", levels(model_df$country_top10)[1], "\n")