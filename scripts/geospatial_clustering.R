# Load required libraries
library(ggplot2)
library(maps)
library(dplyr)
library(cluster)

# Load the processed dataset
data_path <- file.path("data", "processed", "billionaires_analysis_ready.csv")
data <- read.csv(data_path, stringsAsFactors = FALSE)

# Filter data for valid latitude and longitude
geo_data <- data %>%
    filter(!is.na(latitude_country) & !is.na(longitude_country))

# Perform k-means clustering
set.seed(123) # For reproducibility
k <- 5 # Number of clusters
geo_clusters <- kmeans(geo_data[, c("latitude_country", "longitude_country")], centers = k)
geo_data$cluster <- as.factor(geo_clusters$cluster)

# Plot geospatial clusters
world_map <- borders("world", colour = "gray50", fill = "gray80")
geo_plot <- ggplot() +
    world_map +
    geom_point(data = geo_data, aes(x = longitude_country, y = latitude_country, color = cluster), size = 2) +
    scale_color_brewer(palette = "Set1") +
    labs(title = "Geospatial Clustering of Billionaires", x = "Longitude", y = "Latitude", color = "Cluster") +
    theme_minimal()

# Save the plot
output_path <- file.path("output", "geospatial_clustering.png")
ggsave(output_path, plot = geo_plot, width = 10, height = 6)

cat("Geospatial clustering plot saved to:", output_path, "\n")
