# Further Analysis of Significant Categories

# Load required libraries
library(ggplot2)

# Load the processed dataset
data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
data <- read.csv(data_path, stringsAsFactors = FALSE)

# Load p-value results
p_values_path <- file.path("output", "recommended_categorical_analysis.csv")
p_values <- read.csv(p_values_path, stringsAsFactors = FALSE)

# Filter significant categories (p < 0.05)
significant_categories <- p_values %>%
    filter(p_value < 0.05)

# Perform further analysis for each significant category
for (category in significant_categories$category) {
    cat("Analyzing category:", category, "\n")

    # Generate boxplot for the category
    plot <- ggplot(data, aes_string(x = category, y = "log_net_worth")) +
        geom_boxplot(fill = "#5B8FF9", color = "black") +
        labs(
            title = paste("Boxplot of log_net_worth by", category),
            x = category, y = "Log Net Worth"
        ) +
        theme_minimal()

    # Save the plot
    output_path <- file.path("output", "boxplots", paste0("boxplot_", category, ".png"))
    ggsave(output_path, plot = plot, width = 8, height = 5)

    cat("Boxplot saved to:", output_path, "\n")
}
