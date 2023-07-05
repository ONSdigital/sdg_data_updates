# This file is directly called by update_indicator_main.R.
# It has to be called compile_tables.R
# It is the control script that runs all the others.

# list the packages used in this automation - you may need to add some, 
# depending on what you add to the code
packages <- c("stringr", "dplyr", "openxlsx", "tidyr", "janitor", "readr",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "kableExtra")
# install any packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())),
                 dependencies = TRUE, 
                 type = "win.binary")


library(tidyr)
library(readr)
library(dplyr)
library(stringr)
library(tibble)
library(stringr)
library(dplyr)
library(tools)
library(DT)
library(pander)


library(SDGupdater)

if (test_run == TRUE) { source("Example_config.R") } else if (test_run == FALSE) { 
   source("config.R") } else { 
      stop("test_run must be either TRUE or FALSE") }

source("update_6-2-1.R") # does the donkey-work of making the csv - 

# at this point you should see lots of variables appear in the global environment 
# pane (top right). These have been created by the update_4-c-1 script.

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
csv_filename <- paste0(date, "_6-2-1.csv")
qa_filename <- paste0(date, "_6-2-1_checks.html") 

# save files and print messages ------------------------------------------------

write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('6-2-1_checks.Rmd',
                #  output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", 
               paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
