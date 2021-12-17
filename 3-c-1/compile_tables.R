# Author: Emma Wood
# Initial date: 16/12/2021
# purpose: set up for 3-c-1 indicator update, and save output files
#     This file is directly called by update_indicator_main.R.
#     It has to be named compile_tables.R
#     It is the control script that runs all the others.

library('openxlsx')
library('stringr')

source("config.R") # pulls in all the configurations
source("update_3-c-1.R") # does the donkey-work of making the csv

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()
csv_filename <- paste0(date, "_3-c-1.csv")
qa_filename <- paste0(date, "_3-c-1_checks.html") 

write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# If you have a QA document written in Rmarkdown this is how you can run it and save it
rmarkdown::render('QA.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", 
               paste0(getwd(), "/", output_folder,"'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("./..")
