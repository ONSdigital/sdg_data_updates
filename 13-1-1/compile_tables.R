# Author: Steven Jones
# Initial date: 04/11/2022
# purpose: Setup for 13-1-1 indicator update and save output files
#          This file is directly called by update_indicator_main.R.
#          It has to be named compile_tables.R
#          It is the control script that runs all the others.


# list the packages used in this automation - you may need to add some, 
# depending on what you add to the code
packages <- c("stringr", "dplyr", "openxlsx", "tidyr",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")
# install any packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())),
                 dependencies = TRUE, 
                 type = "win.binary")

library('stringr')
library("dplyr")
library('openxlsx')



source("config.R") # pulls in all the configurations
source("recent_data.R")

if (run_historic_data == TRUE){
  source("historical_data.R")
  combined_data <- recent_data_cleaned %>% bind_rows(historic_data_up_to_2012_cleaned)
} else {
  combined_data <- recent_data_cleaned
}

# Remove any rows which might be duplicates
all_cols_but_val <- names(combined_data)[1:(ncol(combined_data)-1)]
combined_data_no_duplicates <- combined_data[!duplicated(combined_data[all_cols_but_val]),]

# Using bind_rows introduces "NA" so replace "NA" with the empty string
combined_data_no_duplicates[is.na(combined_data_no_duplicates)] <- ""

# Sort the data so it looks nice if a user downloads from SDG website

combined_data_no_duplicates_sorted <- combined_data_no_duplicates %>% 
  arrange(Series, `Cause of death`, Country, Sex, Year)


existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()

csv_filename <- paste0(date, "", indicator, ".csv") 
qa_filename <- paste0(date, indicator, "-QA.html") 

write.csv(combined_data_no_duplicates_sorted, paste0(output_folder, "/", csv_filename), row.names = FALSE)

save.image(file = 'img.RData')

rmarkdown::render('13-1-1-QA.Rmd', output_file = paste0(output_folder, "/", qa_filename))


message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
