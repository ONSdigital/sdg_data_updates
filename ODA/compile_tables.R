# This file is directly called by update_indicator_main.R.
# It is the control script that runs all the others.

# library('openxlsx')
# library('stringr')
# library('janitor')
library('unpivotr')
library('tidyxl')
library('tidyr')
library('dplyr')

library(SDGupdater)

source("config.R") # pulls in all the configurations. Change to "config.R" for real update

# import data -------------------------------------------------------------------
oda_data <- read.csv(paste0(input_folder, "/", filename))
exchange_rates <- tidyxl::xlsx_cells(paste0(input_folder, "/", exchange_filename))
deflators <- tidyxl::xlsx_cells(paste0(input_folder, "/", deflators_filename),
                                sheets = "Deflators")


names(oda_data) <- tolower(names(oda_data))

# create stable column names based on elements of column names -----------------

# rename_column <- function(oda_data, patterns, new_name){
#   patterns <- patterns
#   column <- which(apply(sapply(patterns, grepl, names(oda_data)), 1, all) == TRUE)
#   names(oda_data)[column] <- new_name
#   return(oda_data)
# }

oda_renamed <- oda_data %>% 
  rename_column(primary = c("year"), new_name = "year") %>% 
  rename_column(primary = c("extend", "amount"), new_name = "Value") %>% 
  rename_column(primary = c("income", "group"), new_name = "Country_income_classification") %>% 
  rename_column(primary = c("broad", "sector", "code"), new_name = "Broad_sector_code") %>% 
  rename_column(primary = c("sid", "sector"), new_name = "Sector") %>% 
  rename_column(primary = c("sector", "purpose", "text"), new_name = "Type_of_study") %>% 
  rename_column(primary = c("type", "aid", "code"), new_name = "Aid_code") %>% 
  rename_column(primary = c("type", "aid", "text"), new_name = "Aid_description") 

# run code to create specific indicators ---------------------------------------
source("4-b-1.R") 
source("8-a-1.R")

## test:
# source(c("4-b-1.R", "8-a-1.R"))

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
