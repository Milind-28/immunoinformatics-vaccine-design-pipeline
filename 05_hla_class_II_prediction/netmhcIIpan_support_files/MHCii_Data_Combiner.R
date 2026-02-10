library(tidyverse)
library(readxl)
library(writexl)

# Define folder path
cleaned_folder <- "D:/Thaper_Admission/Severe_Fever_With_Thrombocytopenia/SSTWBRLO/netMHCpan_results/Peptide_1_results/Cleaned/"
combined_file_path <- file.path(cleaned_folder, "Peptide_1_results.xlsx")

# Get all cleaned files
file_paths <- list.files(cleaned_folder, pattern = "cleaned_.*\\.xlsx$", full.names = TRUE)

# Function to standardize column types
standardize_types <- function(data) {
  data %>%
    mutate(across(everything(), as.character))  # Convert all columns to character
}

# Read and standardize all files
all_data <- file_paths %>%
  map(read_excel) %>%
  map(standardize_types)

# Combine all standardized data frames
combined_data <- bind_rows(all_data)

# Write the combined data to an Excel file
write.xlsx(combined_data, combined_file_path)

message("Combined data saved to: ", combined_file_path)