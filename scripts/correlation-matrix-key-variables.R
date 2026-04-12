install.packages("psych")
install.packages("corrplot")

library(psych)
library(corrplot)

df <- read.csv(
  "C:\\Users\\siddh\\Downloads\\Billionaires Statistics Dataset.csv",
  stringsAsFactors = FALSE
)

df$gdp_country_numeric <- as.numeric(gsub("[\\$, ]", "", df$gdp_country))

df$log_net_worth <- log(df$finalWorth)

corr_data_small <- df[, c(
  "log_net_worth",
  "age",
  "gdp_country_numeric",
  "cpi_country",
  "total_tax_rate_country"
)]

corr_data_small <- na.omit(corr_data_small)

colnames(corr_data_small) <- c(
  "Log Net Worth",
  "Age",
  "GDP",
  "CPI",
  "Total Tax Rate"
)

cor_matrix_small <- cor(corr_data_small)
print(round(cor_matrix_small, 3))

png(
  filename = "section_4_1_corrplot_compact.png",
  width = 1400,
  height = 1200,
  res = 200
)

corrplot(
  cor_matrix_small,
  method = "number",
  type = "upper",
  diag = TRUE,
  addCoef.col = "black",
  tl.col = "black",
  tl.srt = 30,
  tl.cex = 1.2,
  number.cex = 1,
  mar = c(1, 1, 2, 1),
  title = "Correlation Matrix of Key Variables"
)

dev.off()

corrplot(
  cor_matrix_small,
  method = "number",
  type = "upper",
  diag = TRUE,
  addCoef.col = "black",
  tl.col = "black",
  tl.srt = 30,
  tl.cex = 1.2,
  number.cex = 1,
  title = "Correlation Matrix of Key Variables"
)

corrplot(
  cor_matrix_small,
  method = "color",
  type = "upper",
  addCoef.col = "black",
  tl.col = "black",
  tl.cex = 1.2,
  number.cex = 1,
  title = "Correlation Matrix of Key Variables"
)
