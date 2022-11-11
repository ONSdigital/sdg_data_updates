# Author: Emma Wood
# Initial date: 16/12/2021
# purpose: set up for 3-c-1 indicator update, and save output files
#     This file is directly called by update_indicator_main.R.
#     It has to be named compile_tables.R
#     It is the control script that runs all the others.

library('SDGupdater') # this needs to come before install absent_packages as that is from the SDGupdater package

# list the packages used in this automation - you may need to delete/add some, 
# depending on what you add to the code
packages <- c("stringr", "dplyr", "tools",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")

# this function installs any packages that are not already installed
install_absent_packages(packages)

library('stringr')
library("dplyr")
library("tools")


source("config.R")  # pulls in all the configurations. Un-comment out code below for real update
if (test_run == TRUE) {
  source("example_config.R")
 } else if (test_run == FALSE) {
   source("config.R")
 } else {
   stop("test_run must be either TRUE or FALSE")
 }

source("5-a-1.R") # does the donkey-work of making the csv
# at this point you should see lots of variables appear in the global environment 
# pane (top right). These have been created by the 5-a-1 script.

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(date, "5-a-1.csv")
qa_filename <- paste0(date, "5-a-1.html") 

write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")

