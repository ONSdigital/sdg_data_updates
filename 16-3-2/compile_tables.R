source("config.R")
source("functions.R")

run_date <- Sys.Date()

input_filepath <- paste0(input_folder, "/", input_filename)

if (SDGupdater::get_characters_after_dot(input_filepath) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", config$filename, "as an xlsx and re-run script"))
}

source_data <- tidyxl::xlsx_cells(input_filepath,
                                  sheets = c(age_sex_tabname,
                                             nationality_tabname))

source("sex_age.R")
source("nationality.R")

csv <- bind_rows(csv_sex_age, csv_nationality) %>% 
  distinct()

duplicated_disaggs <- csv %>% 
  group_by(Year, Sex, Age, Nationality) %>% 
  tally() %>% 
  filter(n > 1)

existing_files <- list.files()
if("Output" %not_in% existing_files) {
  dir.create("Output")
}

setwd("Output")

write.csv(csv, paste0("output_", run_date, ".csv"), row.names = FALSE)

setwd('..')
