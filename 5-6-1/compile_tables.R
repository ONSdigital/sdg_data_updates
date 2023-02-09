# This file is directly called by update_indicator_main.R.
# It has to be called compile_tables.R
# It is the control script that runs all the others.

library('SDGupdater') # this needs to come before install absent_packages as that is from the SDGupdater package

# list the packages used in this automation - you may need to delete/add some, 
# depending on what you add to the code
packages <- c("openxlsx", "stringr", "janitor", "tidyr", "dplyr", "readxl",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")



# this function installs any packages that are not already installed
install_absent_packages(packages)

library('openxlsx')
library('stringr')
library('janitor')
library('tidyr')
library('dplyr')
library('readxl')
library('DT')
library('pander')


source("example_config.R") # pulls in all the configurations. Un-comment out code below for real update
#if (test_run == TRUE) {
#  source("example_config.R")
#} else if (test_run == FALSE) {
# source("config.R")
#} else {
# stop("test_run must be either TRUE or FALSE")
#}

source("update_5-6-1.R") # does the donkey-work of making the csv - 

# at this point you should see lots of variables appear in the global environment 
# pane (top right). These have been created by the update_5-6-1.R script.

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
csv_filename <- paste0(date, "_update_5-6-1.csv")
qa_filename <- paste0(date, "_update_5-6-1_checks.html")



# save files and print messages ------------------------------------------------
write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)
rmarkdown::render('update_5-6-1_QA.Rmd', output_file = paste0(output_folder, "/", qa_filename))


# prints a message informing of presence of duplicates (mainly for checking while writing code)
if (check_output == FALSE) {
  message("WARNING: duplicates present in csv_output")
} else if (check_wo_values == FALSE & check_output == TRUE) {
  message("WARNING: duplicates present in csv_output but their values appear to differ")
} else if (check_wo_values == TRUE & check_output == TRUE) {
  message("No duplicates found, good to go")
}

(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))


# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
