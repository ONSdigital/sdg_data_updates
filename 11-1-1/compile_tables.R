# author: Emma Wood
# date: 22/02/2022
# Control script to QA 11-1-1 (there is a different code already written by Max)
# Also used to test template code


packages <- c("stringr", "openxlsx", "tidyr", "dplyr", #"janitor", 
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")
install.packages(setdiff(packages, rownames(installed.packages())),
                 dependencies = TRUE, 
                 type = "win.binary")
library('dplyr')
library('tidyr')
library('openxlsx')
library('stringr')

library('SDGupdater')

source("config.R") 

if (SDGupdater::get_characters_after_dot(areas_filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", areas_filename, "as an xlsx and re-run script"))
}
if (SDGupdater::get_characters_after_dot(households_filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", households_filename, "as an xlsx and re-run script"))
}

area_years_compiled <- NULL
household_years_compiled <- NULL
for(i in 1:length(tabnames)) {
  
  # tabname is year, so we are looping through the years
  tabname <- tabnames[i]
  
  # both data-sets can be reformatted with the same script, with just a change in filename
  # AREAS
  
  filename <- areas_filename
  header_row <- areas_header_row

  source("get_data.R") 
  areas_with_new_columns <- csv_format %>% 
    mutate(Series = "Dwellings (%)",
           Year = tabname)

  area_years_compiled <- area_years_compiled %>% 
    bind_rows(areas_with_new_columns)

 # HOUSEHOLDS
  
  filename <- households_filename
  header_row <- households_header_row
  
  source("get_data.R")
  households_with_new_columns <- csv_format %>% 
    mutate(Series = "Households (%)",
           Year = tabname)
  
  household_years_compiled <- household_years_compiled %>% 
    bind_rows(households_with_new_columns)
}

combined_data <- bind_rows(area_years_compiled, household_years_compiled)

source('clean_combined_data.R')

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date <- Sys.Date()
csv_filename <- paste0(date, "_11-1-1.csv")
# qa_filename <- paste0(date, "_x-x-x_checks.html") 

write.csv(csv_data, 
          paste0(output_folder, "/", csv_filename), 
          row.names = FALSE,
          na = "")


# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('x-x-x_checks.Rmd', output_file = paste0('Output/', qa_filename))
# 
# message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder),
#                " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
