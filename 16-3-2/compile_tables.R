library('SDGupdater')



library('dplyr')
library('tidyr')
library('unpivotr')
library('stringr')
library('tidyxl')

if (test_run == TRUE) {
  source("example_config.R")
} else if (test_run == FALSE) {
  source("config.R")
} else {
  stop("test_run must be either TRUE or FALSE")
}

source("functions.R")

run_date <- Sys.Date()

input_filepath <- paste0(input_folder, "/", input_filename)

if (SDGupdater::get_characters_after_dot(input_filepath) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", config$filename, "as an xlsx and re-run script"))
}

source_data <- tidyxl::xlsx_cells(input_filepath,
                                  sheets = c(age_sex_tabname,
                                             nationality_tabname))

source("sex_age.R")
source("nationality.R")

csv <- bind_rows(csv_sex_age, csv_nationality) %>% 
  distinct()

existing_files <- list.files()
if(output_folder %not_in% existing_files) {
  dir.create(output_folder)
}


write.csv(csv, paste0(output_folder, "/output_", run_date, ".csv"), row.names = FALSE)

rmarkdown::render('16-3-2_checks.Rmd', 
                  output_file = paste0(output_folder, '/16-3-2_checks.html'))


setwd('..')
