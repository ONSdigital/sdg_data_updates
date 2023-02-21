# compile tables for 15.1.1
library('SDGupdater')

packages <- c('openxlsx', 'stringr', 
              'tidyr', 'dplyr', 
              'ggplot2', 'kableExtra', 'pander')

install_absent_packages(packages)

library('dplyr')
library('tidyr')
library('stringr')

if (test_run == TRUE) {
  source("example_config.R")
} else if (test_run == FALSE) {
  source("config.R")
} else {
  stop("test_run must be either TRUE or FALSE")
}

source("update_15-1-1.R")

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}


date <- Sys.Date()
csv_filename <- paste0(date, "_15-1-1.csv")
pre_calculations_filename <- paste0(date, "_before_calcs_15-1-1.csv")

write.csv(csv_formatted, paste0(output_folder, "/", csv_filename), row.names = FALSE)
write.csv(all_data, paste0(output_folder, "/", pre_calculations_filename), row.names = FALSE)

rmarkdown::render('15-1-1_checks.Rmd', 
                  output_file = paste0(output_folder, '/', date ,'_15-1-1_checks.html'))

message(paste0("csv has been created and saved in '", 
               paste0(getwd(), "/", output_folder),
               "' as '", csv_filename, "'\n\n"))

# so we end on the same directory as we started:
setwd("..")

