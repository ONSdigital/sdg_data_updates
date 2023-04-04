# Author: Michael Nairn
# Initial date: 24/03/2032
# purpose: set up for 3-9-3 indicator update, and save output files
#     This file is directly called by update_indicator_main.R.
#     It has to be named compile_tables.R
#     It is the control script that runs all the others.


library(SDGupdater)

packages <- c('tidyr', 'dplyr', 'stringr', 'tibble',
              'tools', 'ggplot2', 'DT', 'pander')

# install_absent_packages(packages)


#load packages
library(tidyr)
library(dplyr)
library(stringr)
library(tibble)
library(stringr)
library(dplyr)
library(tools)
library(DT)
library(pander)



if (test_run == TRUE) { source("example_config.R") } else if (test_run == FALSE) {
  source("config.R") } else {
    stop("test_run must be either TRUE or FALSE") } # pulls in all the configurations for updating indicator 3.4.1.


# run one year of data at a time as the dataset is too big to download all years 
# at once
csv <- NULL

for (i in 1:length(years)) {
  NOMIS_link_temp <- paste0(NOMIS_link, "&date=", years[i])

  
  source("update_3-9-3.R") 
  
  csv <- bind_rows(csv, csv_output)
}

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) 
  dir.create(output_folder)


date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(date, "_3-9-3.csv")
qa_filename <- paste0(date, "_3-9-3.html") 

write.csv(csv, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
rmarkdown::render('3-9-3_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")