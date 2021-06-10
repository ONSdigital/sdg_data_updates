source("config.R")
source("functions.R")

input_filepath <- paste0(input_folder, "/", input_filename)

if (SDGupdater::get_characters_after_dot(input_filepath) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", config$filename, "as an xlsx and re-run script"))
}

source_data <- tidyxl::xlsx_cells(input_filepath,
                                  sheets = c(age_sex_tabname,
                                             nationality_tabname))

source(sex_age)