library(tidyverse)
library(readxl)
library(hms)
library(zoo)
library(writexl)
library(openxlsx)

# Define folder paths
input_folder <- "D:/Thaper_Admission/Severe_Fever_With_Thrombocytopenia/SSTWBRLO/netMHCIIpan_results/Peptide_4_results/"
output_folder <- file.path(input_folder, "Cleaned")

# Create output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
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
      str_replace("Unnamed:\\d*", NA_character_) %>%
      str_remove("\\...\\d*")
    
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
      if (!is.na(head1[.x]) & !is.na(head2[.x])) {
        paste(head1[.x], head2[.x], sep = "__")
      } else {
        head2[.x]
      }
    })
    
    raw_data <- read_excel(file_path, skip = 2, col_names = headers)
    
    mcol1 <- which(str_detect(headers, "HLA-|DR")) %>% first()
    if (is.na(mcol1)) stop("No 'HLA-' or 'DR' columns found in file: ", file_path)
    
    # Pivot longer safely using column names
    tidy_data <- raw_data %>%
      pivot_longer(cols = all_of(names(raw_data)[mcol1:ncol(raw_data)]),
                   names_to = "KEY", values_to = "VALUE") %>%
      separate(KEY, into = c("HLA_Type", "Metric"), sep = "__") %>%
      group_by(across(-VALUE)) %>%
      summarise(VALUE = first(VALUE), .groups = "drop") %>%  # De-duplicate
      pivot_wider(names_from = Metric, values_from = VALUE)
    
    # Filter columns safely
    cols_to_remove <- intersect(c("Pos", "ID", "Ave", "Target", "NB"), names(tidy_data))
    tidy_data <- tidy_data[, !names(tidy_data) %in% cols_to_remove]
    
    # Clean and filter Rank
    tidy_data$Rank <- suppressWarnings(as.numeric(tidy_data$Rank))
    tidy_data <- tidy_data[!is.na(tidy_data$Rank) & tidy_data$Rank < 5.00, ]
    
    # Optional: Summary of how many peptides per HLA
    #summary <- tidy_data %>%
      #count(HLA_Type, name = "Peptide_Count")
    
    # Write cleaned data and summary to same Excel file
    output_file <- file.path(output_folder, paste0("cleaned_", basename(file_path)))
    write.xlsx(list(Cleaned_Data = tidy_data), output_file)
    
    message("✅ Processed: ", file_path, " -> ", output_file)
  }, error = function(e) {
    message("❌ Error processing file: ", file_path, "\n", e)
  })
}
