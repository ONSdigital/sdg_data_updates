# These files will only work for 3-2-1 for the data for 2020 onwards, as the table format has changed since
# There is an automation for the older data that was never used in the 3-2-1 branch on github, this will be in 3-2-1_new

# This file is directly called by update_indicator_main.R.
# It has to be called compile_tables.R
# It is the control script that runs all the others.

library('SDGupdater') # this needs to come before install absent_packages as that is from the SDGupdater package

# list the packages used in this automation - you may need to delete/add some, 
# depending on what you add to the code
packages <- c("stringr", "unpivotr", "tidyxl", "tidyr", "dplyr", "rsdmx", "openxlsx", "readxl", "janitor",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")

# this function installs any packages that are not already installed
install_absent_packages(packages)

# please check that all the libraries required are called here
library('Rccp')
library('stringr')
library('unpivotr')
library('tidyxl')
library('tidyr')
library('dplyr')
library('rsdmx')
library('openxlsx')
library('readxl')
library('janitor')


source("example_config.R") # pulls in all the configurations. Un-comment out code below for real update
# if (test_run == TRUE) {
#   source("example_config.R")
# } else if (test_run == FALSE) {
#   source("config.R")
# } else {
#   stop("test_run must be either TRUE or FALSE")
# }


# check file is correct type
if (SDGupdater::get_characters_after_dot(filename) != "xlsx") {
  stop(paste0("File must be an xlsx file. Save ", filename, " as an xlsx file and re-run script."))
}


source_data <- xlsx_cells(paste0(input_folder, "/", filename),
                                 sheets = c(tabname_UK, tabname_EW))


source("update_type_1.R") # does the donkey-work of making the csv - 
                          # for real update this might be called e.g. 'update_1-2-1.R' 

# at this point you should see lots of variables appear in the global environment 
# pane (top right). These have been created by the update_type_1 script.

# create an output file if one does not already exist --------------------------
existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

# create elements we will use to name files ------------------------------------

date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(date, "_update_type_1.csv")
qa_filename <- paste0(date, "_update_type_1_checks.html") 

# save files and print messages ------------------------------------------------

write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
