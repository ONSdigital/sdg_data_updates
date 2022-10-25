# Author: Emma Wood
# Initial date: 24/10/2022
# purpose: 3-9-1 - data using the new method

packages <- c("stringr", "dplyr", "tidyr",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")
# install any packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())),
                 dependencies = TRUE, 
                 type = "win.binary")

library("stringr")
library("dplyr")
library("tidyr")

source("example_config.R") 
source("update_3-9-1.R") 

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(date, "_update_type_4.csv")
qa_filename <- paste0(date, "_update_type_4_checks.html") 

write.csv(csv_output, 
          paste0(output_folder, "/", csv_filename), 
          row.names = FALSE,
          na = "")

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")

