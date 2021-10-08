source("config.R")

# filename <- SDGupdater::ask_user_for_filename(input_folder)

if (SDGupdater::get_characters_after_dot(filename) != "xlsx") {
  stop(paste("File must be an xlsx file. Save", filename, "as an xlsx and re-run script"))
}

source_data <- tidyxl::xlsx_cells(paste0(input_folder, "/", filename),
                                  sheets = c(area_of_residence_tab_name,
                                             birthweight_by_mum_age_tab_name,
                                             country_of_occurrence_by_sex_tab_name,
                                             country_of_birth_tab_name))

source("region.R")
source("birthweight_by_mum_age.R")
source("country_of_occurence_by_sex.R")
source("country_of_birth.R")

age_order <- data.frame(Age = c("19 and under",
                                "20 to 24",
                                "25 to 29",
                                "30 to 34",
                                "35 to 39",
                                "40 and over"),
                        age_order = c(1:6))
weight_order <- data.frame(Birthweight = c("Under 2500",
                                           "Under 1500",
                                           "Under 1000",
                                           "1000 to 1499",
                                           "1500 to 1999",
                                           "2000 to 2499",
                                           "2500 to 2999",
                                           "3000 to 3499",
                                           "3500 to 3999",
                                           "4000 and over",
                                           "Implausible birthweight",
                                           "Not stated"),
                           weight_order = c(1:12))
country_order <- data.frame(Country = c("England and Wales",
                                        "England and Wales linked deaths",
                                        "England",
                                        "Northern Ireland",
                                        "Scotland",
                                        "Wales"),
                            country_order = c(1:6))

all_csv_data <- dplyr::bind_rows(clean_csv_data_area_of_residence,
                                 clean_csv_data_birtweight_by_mum_age,
                                 clean_csv_data_country_by_sex,
                                 clean_csv_data_country_of_birth) %>%
  dplyr::left_join(age_order, by = "Age") %>% 
  dplyr::left_join(country_order, by = "Country") %>% 
  dplyr::left_join(weight_order, by = "Birthweight") %>% 
  dplyr::mutate(`Unit measure` = "Rate per 1,000 live births",
                `Unit multiplier` = "Units",
                `Observation status` = "Undefined",
                GeoCode = ifelse(is.na(GeoCode), "", as.character(GeoCode))) %>% 
  dplyr::arrange(`Neonatal period`, age_order, weight_order, country_order, 
                 Region, Sex) %>%
  dplyr::select(Year, `Neonatal period`, Age, Birthweight, Country, Region, `Country of birth`, Sex, 
                GeoCode, `Unit measure`, `Unit multiplier`, `Observation status`, Value)


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

date_time <- Sys.time()
filename_date_time <- SDGupdater::create_datetime_for_filename(date_time)

csv_data_filename <- paste0('Output/', filename_date_time, "_3-2-2_data_for_", year, ".csv")
markdown_filename <- paste0('Output/',filename_date_time, "_3-2-2_QA_for_", year, ".html")

write.csv(csv_data, csv_data_filename, row.names = FALSE)
rmarkdown::render('QA.Rmd', output_file = markdown_filename)

message(paste0("csv for ", year, " has been created and saved in '", current_directory,
             "' as '", csv_data_filename, "\n\n",
             " Rows that didn't have values (supressed) are saved as '", no_value_rows_filename, "'"))

# so we end on the same directory as we started:
setwd("./..")

