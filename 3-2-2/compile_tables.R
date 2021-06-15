config <- config::get()

# filename <- SDGupdater::ask_user_for_filename(config$input_folder)

if (SDGupdater::get_characters_after_dot(config$filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", config$filename, "as an xlsx and re-run script"))
}

source_data <- tidyxl::xlsx_cells(paste0(config$input_folder, "/", config$filename),
                                  sheets = c(config$area_of_residence_tab_name,
                                             config$birthweight_by_mum_age_tab_name,
                                             config$country_of_occurrence_by_sex_tab_name))

source("region.R")
source("birthweight_by_mum_age.R")
source("country_of_occurence_by_sex.R")

all_csv_data <- dplyr::bind_rows(clean_csv_data_area_of_residence,
                                 clean_csv_data_birtweight_by_mum_age,
                                 clean_csv_data_country_by_sex) %>%
  dplyr::mutate(`Unit measure` = "Rate per 1,000 live births",
                `Unit multiplier` = "Units",
                `Observation status` = "Undefined") %>%
  dplyr::select(Year, Sex, Country, Region, `Health board`, Birthweight, Age, `Neonatal period`, GeoCode,
                `Unit measure`, `Unit multiplier`, `Observation status`, Value)


no_value_rows <- all_csv_data %>%
  dplyr::filter(is.na(Value))

csv_data <- all_csv_data %>%
  dplyr::filter(!is.na(Value))


current_directory <- getwd()
year <- SDGupdater::unique_to_string(SDGupdater::get_all_years(all_csv_data$Year))

# Don't want to overwrite an Output folder that already exists, or depend on the user having remembered to create an Output folder themselves
existing_files <- list.files()
output_folder_exists <- ifelse("Output" %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create("Output")
}

setwd('./Output')

date_time <- Sys.time()
filename_date_time <- SDGupdater::create_datetime_for_filename(date_time)

csv_data_filename <- paste0(filename_date_time, "_3-2-2_data_for_", year, ".csv")
no_value_rows_filename <- paste0(filename_date_time, "rows_without_values_in_", year, ".csv")

write.csv(csv_data, csv_data_filename, row.names = FALSE)
write.csv(no_value_rows, no_value_rows_filename, row.names = FALSE)

message(paste0("csv for ", year, " has been created and saved in '", current_directory,
             "' as '", csv_data_filename, "\n\n",
             " Rows that didn't have values (supressed) are saved as '", no_value_rows_filename, "'",
             "'\n\nFiles created for individual tabs can be viewed by clicking on them in the Global Environment."))

# To Do: this fix could be automated/ put in a markdown run report
message(paste0("\n Please check that year is entered correctly in the csv.\n",
               "Year should be the same for all rows in the output csv.\n",
               "If there is a superscript immediately after year in the top of one of the input excel tabs, year may not be enetered, so will need to be manually filled in"))

# so we end on the same directory as we started:
setwd("./../..")

