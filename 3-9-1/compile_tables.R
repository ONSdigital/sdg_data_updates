# Author: Emma Wood
# Initial date: 24/10/2022
# purpose: 3-9-1 - data using the new method

library("SDGupdater")

packages <- c("stringr", "dplyr", "tidyr",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")
install_absent_packages(packages)

library("stringr")
library("dplyr")
library("tidyr")

if (test_run == TRUE) {
  source("example_config.R")
} else if (test_run == FALSE) {
  source("config.R")
} else {
  stop("test_run must be either TRUE or FALSE")
}

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

# download and read in data ----------------------------------------------------
old_data <- read.csv(paste0(input_folder, "/", old_method_filename)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_squish)) 

new_data <- read.csv(paste0(input_folder, "/", new_method_filename)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_squish)) 

datasets <- list(old_data, new_data)

csv_compiled <- NULL
required_compiled <- NULL
deprivation_note_compiled <- NULL

for (i in 1:length(datasets)) {
  dat <- datasets[[i]]
  source("update_3-9-1.R")
  
  csv_compiled <- bind_rows(csv_compiled, csv_formatted)
  required_compiled <- bind_rows(required_compiled, required_data)
  deprivation_note_compiled <- bind_rows(deprivation_note_compiled, deprivation_note)
}

date <- Sys.Date()

csv_filename <- paste0(date, "_update_3-9-1.csv")
qa_filename <- paste0(date, "_3-9-1_checks.html") 

write.csv(csv_compiled, 
          paste0(output_folder, "/", csv_filename), 
          row.names = FALSE,
          na = "")

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")

