# Author: Emma Wood 
# compile tables for indicator 13-2-2
library(SDGupdater)

packages <- c('tidyxl', 'dplyr', 'stringr', 'unpivotr',
              'tidyr', 'ggplot2', 'DT', 'pander')

install_absent_packages(packages)

library(tidyxl)
library(dplyr)
library(stringr)
library(unpivotr)

#--- get input from user ---
# pull in all the configurations based on whether it is a test run or not
if (test_run == TRUE) {
  source("example_config.R")
} else if (test_run == FALSE) {
  source("config.R")
} else {
  stop("test_run must be either TRUE or FALSE")
}

if (SDGupdater::get_characters_after_dot(filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", filename, "as an xlsx and re-run script"))
}

source("by_gas_type.R") 

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

csv_filename <- paste0(date, "_13-2-2.csv")
qa_filename <- paste0(date, "_13-2-2_checks.html") 

write.csv(csv_formatted, paste0(output_folder, "/", csv_filename), row.names = FALSE)
rmarkdown::render('update_13-2-2_QA.Rmd', output_file = paste0(output_folder, "/", qa_filename))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")


