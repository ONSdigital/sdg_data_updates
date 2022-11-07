# This file is directly called by update_indicator_main.R.
# It is the control script that runs all the others.

library('SDGupdater')

packages <- c("stringr", "unpivotr", "tidyxl", "tidyr", "dplyr", "rsdmx",
              # packages used in the Rmarkdown script (library called there):
              "ggplot2", "DT", "pander")

install_absent_packages(packages)

library('stringr')
library('unpivotr')
library('tidyxl')
library('tidyr')
library('dplyr')
library('rsdmx')

if (test_run == TRUE) {
  source("example_config.R")
} else if (test_run == FALSE) {
  source("config.R")
} else {
  stop("test_run must be either TRUE or FALSE")
}

# create filepaths for exchange rates and deflators files ----------------------
rates_filepath <- paste0(input_folder, "/", exchange_filename)
deflators_filepath <- paste0(input_folder, "/", deflators_filename)

# create an output file if one does not already exist --------------------------
existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

# create elements we will use to name files ------------------------------------

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
date <- Sys.Date()

# import data -------------------------------------------------------------------
# exchange rate and deflator data are imported using the gbp_to_constant_usd 
# function so don't need to do that here
new_oda_data <- read.csv(paste0(input_folder, "/", filename_newdat)) %>% 
  mutate(across(where(is.factor), as.character))
names(new_oda_data) <- tolower(names(new_oda_data))

old_oda_data <- read.csv(paste0(input_folder, "/", filename_2017)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(sectorpurposetext = "") # column not in older data. Required so 4-b-1 code runs on both old and new data.
names(old_oda_data) <- tolower(names(old_oda_data))

# could move to 1-a-1 file if this is the only indicator using GNI

if ("1-a-1" %in% indicators) {
  gni_end_year <- format(Sys.Date(), "%Y")
  gni_api <- paste0("https://stats.oecd.org/restsdmx/sdmx.ashx/GetData/TABLE1/12+12.1.1.1140+1160.N/all?startTime=",
                    gni_start_year, "&endTime=", gni_end_year)
  try(gni_sdmx <- readSDMX(gni_api))
  try(gni_data <- as.data.frame(gni_sdmx))
}

# create stable column names based on elements of column names -----------------

oda_datasets <- list(old_oda_data, new_oda_data)
oda_renamed_list <- list()

for (i in 1:2) {
  
  oda_renamed_list[[i]] <- oda_datasets[[i]] %>% 
    rename_column(primary = c("year"), new_name = "year") %>% 
    rename_column(primary = c("extend", "amount"), new_name = "gross_oda") %>% 
    rename_column(primary = c("income", "group"), new_name = "country_income_classification") %>% 
    rename_column(primary = c("broad", "sector", "code"), new_name = "broad_sector_code") %>% 
    rename_column(primary = c("sid", "sector"), new_name = "sector") %>% 
    rename_column(primary = c("sector", "purpose", "code"), new_name = "sector_purpose_code") %>% 
    rename_column(primary = c("sector", "purpose", "text"), new_name = "type_of_study") %>% 
    rename_column(primary = c("type", "aid", "code"), new_name = "aid_code") %>% 
    rename_column(primary = c("type", "aid", "text"), new_name = "aid_description") %>% 
    rename_column(primary = c("headline", "oda", "thousands"), # some indicators may use net oda while others use amounts extended (value)
                  alternate = c("net", "oda", "thousands"), new_name = "net_oda")
}

# run code to create specific indicators ---------------------------------------
scripts_run <- c()

for (i in 1:length(indicators)) {
  
  script_name <- paste0(indicators[i], ".R")  
  
  # because we need to run each indicator script twice (for pre and post 2017)
  # and then bind the data together, we can't just name the dataframe with the
  # indicator number in the indicator script as it will get overwritten when
  # the second dataset is run.
  csv_name <- paste0("csv_", 
    str_remove(
      str_replace_all(script_name, "-", ""),
      ".R"))
  
  # initiate a dataframe to hold both pre and post 2017 data for indicator i
  all_years <- NULL
  
  for (j in 1:2) {
    
    oda_renamed <- oda_renamed_list[[j]]
    
    try(
      source(script_name)
    )
    
    try(
      all_years <- bind_rows(all_years, csv) %>% 
        mutate(Value = round(Value, 3))
    )
    
  }
  # to avoid duplication of indicators in the scripts run vector caused by
  # running the script on both archived and recent data:
  scripts_run <- unique(scripts_run)
  
  # so that we don't overwrite the data from the previous indicator script:
  assign(csv_name, all_years)
  
  # in order to identify whether the current run was successful compare the current
  # csv_name with the old one. If they are the same the current loop has not 
  # produced anything new
  if (i > 1) {
    iteration_worked <- length(scripts_run) != previous_count
  } else {
    iteration_worked <- TRUE
  }
  
  if (iteration_worked == TRUE) {
    csv_filename <- paste0(date, "_update_", indicators[i], ".csv")
    write.csv(all_years, paste0(output_folder, "/", csv_filename), row.names = FALSE)
    
  }
  
  previous_count <- length(scripts_run)
  print(scripts_run)

}


qa_filename <- paste0(date, "_oda_update_checks.html") 

# save files and print messages ------------------------------------------------


# # If you have a QA document written in Rmarkdown this is how you can run it and save it
rmarkdown::render('ODA_QA.Rmd', 
                  output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA files have been created and saved in '", 
               paste0(getwd(), "/", output_folder, "'"), 
               ". It is possible that not all indicators ran successfully -
               please check oda_update_checks.Rmd"))

# so we end on the same directory as we started before update_indicator_main.R was run:
setwd("..")
