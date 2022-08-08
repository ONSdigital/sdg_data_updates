# This file is directly called by update_indicator_main.R.
# It is the control script that runs all the others.

# library('openxlsx')
library('stringr')
# library('janitor')
library('unpivotr')
library('tidyxl')
library('tidyr')
library('dplyr')
library('rsdmx')

library(SDGupdater)

source("config.R") # pulls in all the configurations. Change to "config.R" for real update

# create filepaths for exchange rates and deflators files ----------------------
rates_filepath <- paste0(input_folder, "/", exchange_filename)
deflators_filepath <- paste0(input_folder, "/", deflators_filename)

# import data -------------------------------------------------------------------
# exchange rate and deflator data are imported using the gbp_to_constant_usd 
# function so don't need to do that here
oda_data <- read.csv(paste0(input_folder, "/", filename))
names(oda_data) <- tolower(names(oda_data))

# could move to 1-a-1 file if this is the only indicator using GNI

if ("1-a-1" %in% indicators) {
  gni_end_year <- format(Sys.Date(), "%Y")
  gni_api <- paste0("https://stats.oecd.org/restsdmx/sdmx.ashx/GetData/TABLE1/12+12.1.1.1140+1160.N/all?startTime=",
                    gni_start_year, "&endTime=", gni_end_year)
  gni_sdmx <- readSDMX(gni_api)
  gni_data <- as.data.frame(gni_sdmx)
}

# create stable column names based on elements of column names -----------------

# rename_column <- function(oda_data, patterns, new_name){
#   patterns <- patterns
#   column <- which(apply(sapply(patterns, grepl, names(oda_data)), 1, all) == TRUE)
#   names(oda_data)[column] <- new_name
#   return(oda_data)
# }

oda_renamed <- oda_data %>% 
  rename_column(primary = c("year"), new_name = "year") %>% 
  rename_column(primary = c("extend", "amount"), new_name = "value") %>% 
  rename_column(primary = c("income", "group"), new_name = "country_income_classification") %>% 
  rename_column(primary = c("broad", "sector", "code"), new_name = "broad_sector_code") %>% 
  rename_column(primary = c("sid", "sector"), new_name = "sector") %>% 
  rename_column(primary = c("sector", "purpose", "code"), new_name = "sector_purpose_code") %>% 
  rename_column(primary = c("sector", "purpose", "text"), new_name = "type_of_study") %>% 
  rename_column(primary = c("type", "aid", "code"), new_name = "aid_code") %>% 
  rename_column(primary = c("type", "aid", "text"), new_name = "aid_description") %>% 
  rename_column(primary = c("headline", "oda", "thousands"), new_name = "oda")

# run code to create specific indicators ---------------------------------------
scripts_run <- c()

for (i in 1:length(indicators)) {
  script_name <- paste0(indicators[i], ".R")
  try(source(script_name))
}









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
