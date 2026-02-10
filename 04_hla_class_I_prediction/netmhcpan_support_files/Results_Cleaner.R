# NetMHCpan Output Cleaning and Normalization Script
# Purpose: Standardizes raw NetMHCpan HLA Class I prediction outputs
# into analysis-ready tabular formats for downstream filtering.
# Developed during MSc Biotechnology thesis (2023–2025)

library(tidyverse)
library(readxl)
library(hms)
library(zoo)
library(writexl)
library(openxlsx)

# Define the list of folder paths
input_folders <- "D:/Thaper_Admission/Severe_Fever_With_Thrombocytopenia/SSTWBRLO/Examples/NetMHCpan/Netmhcpan_result"
output_base_folder <- "D:/Thaper_Admission/Severe_Fever_With_Thrombocytopenia/SSTWBRLO/Examples/NetMHCpan/Cleaned/"

# Loop through each folder
for (input_folder in input_folders) {
  # Define the corresponding output folder
  folder_name <- basename(normalizePath(input_folder))
  output_folder <- file.path(output_base_folder, folder_name)
  
  # Create output folder if it doesn't exist
  if (!dir.exists(output_folder)) {
    dir.create(output_folder, recursive = TRUE)
  }
  
  # Get all Excel files in the input folder
  file_list <- list.files(input_folder, pattern = "\\.xlsx$", full.names = TRUE)
  
  # Process each file
  for (file_path in file_list) {
    tryCatch({
      # Read and process headers
      head1 <- read_excel(file_path, col_names = TRUE) %>%
        names() %>%
        str_replace("Unnamed:\\d*", NA_character_)
      
      head2 <- read_excel(file_path, skip = 1, col_names = TRUE) %>% 
        names() %>% 
        str_replace("Unnamed:\\d*", NA_character_)
      
      head2 <- head2 %>% str_remove("\\...\\d*")
      
      ncols <- length(head1)
      for (n in 1:ncols) {
        if (is.na(head2[n])) {
          head2[n] <- head1[n]
          head1[n] <- NA_character_
        }
      }
      
      head1 <- tibble(head1) %>% 
        mutate(head1 = zoo::na.locf0(head1)) %>% 
        pull()
      
      headers <- map_chr(1:ncols, ~ {
        case_when(
          !is.na(head1[.x]) & !is.na(head2[.x]) ~ paste(head1[.x], head2[.x], sep = "_"),
          TRUE ~ head2[.x]
        )
      })
      
      raw_data <- read_excel(file_path, skip = 2, col_names = headers)
      
      mcol1 <- which(str_detect(headers, "HLA-")) %>% first()
      
      # Tidy the data
      tidy_data <- raw_data %>%
        pivot_longer(cols = mcol1:ncol(raw_data), names_to = "KEY", values_to = "VALUE") %>%
        separate(KEY, into = c("HLA_Type", "Metric"), sep = "_") %>%
        pivot_wider(names_from = Metric, values_from = VALUE)
      
      # Filter and clean
      tidy_data <- tidy_data[, !names(tidy_data) %in% c("Pos", "ID", "Ave", "NB")]
      tidy_data$EL <- as.numeric(tidy_data$EL)
      tidy_data <- tidy_data[tidy_data$EL < 2.00, ]
      
      # Write the output
      output_file <- file.path(output_folder, paste0("cleaned_", basename(file_path)))
      write.xlsx(tidy_data, output_file)
      
      message("Processed: ", file_path, " -> ", output_file)
    }, error = function(e) {
      message("Error processing file: ", file_path, "\n", e)
    })
  }
}
