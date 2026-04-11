# Category vs. Category Grid Correlation Analysis

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# Load the processed dataset
data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
data <- read.csv(data_path, stringsAsFactors = FALSE)

# Identify categorical columns
categorical_cols <- names(data)[sapply(data, is.character)]

# Perform pairwise category analysis
results <- data.frame(category1 = character(), category2 = character(), p_value = numeric(), stringsAsFactors = FALSE)

for (i in 1:(length(categorical_cols) - 1)) {
    for (j in (i + 1):length(categorical_cols)) {
        cat1 <- categorical_cols[i]
        cat2 <- categorical_cols[j]

        # Perform chi-squared test
        contingency_table <- table(data[[cat1]], data[[cat2]])
        test_result <- chisq.test(contingency_table)

        # Store results
        results <- rbind(results, data.frame(category1 = cat1, category2 = cat2, p_value = test_result$p.value))
    }
}

# Filter significant results
significant_results <- results %>% filter(p_value < 0.05)

# Save the results
output_path <- file.path("output", "category_vs_category_analysis.csv")
write.csv(significant_results, output_path, row.names = FALSE)

# Generate grid of correlation plots
for (row in 1:nrow(significant_results)) {
    cat1 <- significant_results$category1[row]
    cat2 <- significant_results$category2[row]

    plot <- ggplot(data, aes_string(x = cat1, fill = cat2)) +
        geom_bar(position = "dodge") +
        labs(title = paste("Correlation between", cat1, "and", cat2), x = cat1, fill = cat2) +
        theme_minimal()

    # Save the plot
    plot_path <- file.path("output", "barplots", paste0("correlation_", cat1, "_vs_", cat2, ".png"))
    ggsave(plot_path, plot = plot, width = 10, height = 6)
}
