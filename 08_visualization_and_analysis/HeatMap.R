# Load required libraries
library(ggplot2)
library(reshape2)
library(RColorBrewer)
library(openxlsx)
library(scales)

# Method 4: Reading data from file and creating heatmap
# Uncomment and modify the path to your data file
data <- read.xlsx("HLA_Class_II.xlsx")
# Set the first column as row names and remove it from the data frame
rownames(data) <- data[[1]]
data <- data[,-1]

# Convert to matrix for heatmap plotting
data_matrix <- as.matrix(data)

# Convert to long format
data_long <- melt(data_matrix)
colnames(data_long) <- c("Peptides", "HLA_Class_II", "Value")

data_long$fill_color <- viridis::viridis(n = 100)[
  as.numeric(cut(data_long$Value, breaks = 100))
]

# Compute brightness (simple average of RGB)
rgb_vals <- col2rgb(data_long$fill_color)
brightness <- (0.299 * rgb_vals[1, ] + 0.587 * rgb_vals[2, ] + 0.114 * rgb_vals[3, ])  # Luminance formula
data_long$text_color <- ifelse(brightness < 130, "white", "black")  # threshold can be tuned

# Plot with enhanced legend and bold labels
ggplot(data_long, aes(x = HLA_Class_II, y = Peptides, fill = Value)) +
  geom_tile(color = "black") +
  scale_fill_viridis_c(option = "viridis") +
  theme_minimal() +
  theme(
    # Make all text bold
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 10),
    axis.text.y = element_text(face = "bold", size = 10),
    axis.title.x = element_text(face = "bold", size = 12),
    axis.title.y = element_text(face = "bold", size = 12),
    plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(face = "bold", size = 10),
    
    # Adjust legend positioning and size
    legend.position = "right",
    legend.margin = margin(l = 10),  # Reduce left margin to bring legend closer
    legend.key.width = unit(0.8, "cm"),  # Make legend width smaller
    legend.key.height = unit(3, "cm"),   # Make legend height match heatmap better
    
    # Reduce plot margins to bring legend closer
    plot.margin = margin(t = 20, r = 10, b = 20, l = 20, unit = "pt")
  ) +
  guides(
    fill = guide_colorbar(
      title = "",
      title.position = "top",
      title.hjust = 0.5,
      barwidth = 1,
      barheight = 20,  # Make the color bar taller to match heatmap height better
      frame.colour = "black",
      frame.linewidth = 0.5
    )
  ) +
  labs(
    title = "", 
    x = "HLA Class II",
    y = "Peptides"
  )

#geom_text(aes(label = round(Value), color = text_color), size = 3, show.legend = FALSE) +
#scale_color_identity()  # Use exact colors from text_color

# Save heatmap to file
# ggsave("heatmap.png", width = 10, height = 8, dpi = 300)