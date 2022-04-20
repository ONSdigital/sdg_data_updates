# date: 20/04/2022
# automation for 3-2-2 for data published from 2022 onward
# birth weight and mother age disaggregations

header_row <- first_header_row_country_of_birth 

# read in data -----------------------------------------------------------------

if (header_row == 1) {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = country_of_birth_tab_name, 
                                     colNames = TRUE)  
} else {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = country_of_birth_tab_name, 
                                     colNames = FALSE, skipEmptyRows = FALSE) 
}

# clean the columns that contain strings ---------------------------------------

clean_data <- source_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))

# separate the data from the above-table metadata ------------------------------

if (header_row > 1) {
  data_no_headers <- clean_data[(header_row + 1):nrow(clean_data), ]
  
  # only use the following if you need the country and year info contained above the headers 
  # (it may be useful to put the details the are output in the QA file)
  metadata <- get_info_cells(clean_data, header_row, "xlsx")
  year <- unique_to_string(metadata$Year) # only if year is expected in the info above the header
  country <- unique_to_string(metadata$Country) # only if country is expected in the info above the header
  
} else {
  year <- NA
  country <- NA
}

# clean the column names -------------------------------------------------------
if (header_row > 1){
  with_headers <- data_no_headers
  names(with_headers) <- clean_data[header_row, ]
  
  # if you import a csv, numbers will now be read as characters - you can rectify this here
  # NOTE: check that data types are what you expect after running this!
  main_data <-  with_headers %>% 
    type.convert(as.is = TRUE) 
  
} else {
  main_data <- clean_data 
  names(main_data) <- SDGupdater::remove_superscripts(names(main_data)) 
  
}

main_data <- clean_names(main_data)


#continue from here















# make column names consistent across years ------------------------------------

renamed_main <- main_data %>% 
  rename_column(primary = c("rate", "neo"), 
                not_pattern = "peri|post|early",
                new_name = "neonatal_rate") %>% 
  rename_column(primary = c("live", "birth"), 
                new_name = "number_live_births") %>% 
  rename_column(primary = c("early", "neo", "death"),
                not_pattern = "rate|post|peri",
                new_name = "number_early_neonatal_deaths") %>% 
  rename_column(primary = c("neo", "death"),
                not_pattern = "rate|post|peri|early",
                new_name = "number_neonatal_deaths") %>% 
  rename_column(primary = "weight",
                new_name = "birthweight") %>% 
  rename_column(primary = c("mother", "age"),
                new_name = "mother_age") 








clean_data <- countries_to_keep %>% 
  left_join(tidy_data, by = c("mother_country", "birthweight")) %>%
  dplyr::filter(!is.na(numeric)) %>% #to remove cells that are just ends of a header that have run on to the next row
  dplyr::select(-local_format_id)

data_for_calculations <- clean_data %>%
  tidyr::pivot_wider(names_from = c(measure, baby_age, event),
                     values_from = numeric)

# rename columns so they are the same each year --------------------------------

data_for_calculations <- name_columns(data_for_calculations, 
                                      c("Rates", "Neo"),
                                      "Neonatal_rate")
data_for_calculations <- name_columns(data_for_calculations, 
                                      c("Live"),
                                      "number_live_births")
data_for_calculations <- name_columns(data_for_calculations, 
                                      c("Numbers", "Early"),
                                      "number_early_neonatal_deaths")
data_for_calculations <- name_columns(data_for_calculations, 
                                      c("Numbers", "Neo", "Deaths"),
                                      "number_neonatal_deaths")
#-------------------------------------------------------------------------------

calculations_country_of_birth <- data_for_calculations %>%
  dplyr::mutate(number_late_neonatal_deaths = number_neonatal_deaths - number_early_neonatal_deaths) %>%
  dplyr::mutate(Late_neonatal_rate = SDGupdater::calculate_valid_rates_per_1000(number_late_neonatal_deaths,
                                                                                number_live_births, decimal_places),
                
                Early_neonatal_rate = SDGupdater::calculate_valid_rates_per_1000(number_early_neonatal_deaths,
                                                                                 number_live_births, decimal_places),
                
                # overall neonatal rates are calculated already in the download, so we can check our calcs against these
                Rates_Neonatal_check = SDGupdater::calculate_valid_rates_per_1000(number_neonatal_deaths,
                                                                                  number_live_births, decimal_places)) %>% 
  dplyr::mutate(obs_status_early = case_when(
    number_early_neonatal_deaths < 3 | is.na(number_early_neonatal_deaths) ~ "Missing value; suppressed", 
    number_early_neonatal_deaths >= 3 & number_early_neonatal_deaths <= 19 ~ "Low reliability",
    number_early_neonatal_deaths > 19  ~ "Normal value"),
    obs_status_late = case_when(
      number_late_neonatal_deaths < 3 | is.na(number_early_neonatal_deaths) ~ "Missing value; suppressed", 
      number_late_neonatal_deaths >= 3 & number_late_neonatal_deaths <= 19 ~ "Low reliability",
      number_late_neonatal_deaths > 19  ~ "Normal value"),
    obs_status_neonatal = case_when(
      number_neonatal_deaths < 3 | is.na(number_early_neonatal_deaths) ~ "Missing value; suppressed", 
      number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
      number_neonatal_deaths > 19  ~ "Normal value"))

number_of_rate_calculation_mismatches <- SDGupdater::count_mismatches(
  calculations_country_of_birth$Rates_Neonatal_check, calculations_country_of_birth$Neonatal_rate)


data_in_csv_format <- calculations_country_of_birth %>%
  dplyr::select(mother_country,
                Early_neonatal_rate, Late_neonatal_rate, Neonatal_rate,
                obs_status_early, obs_status_late, obs_status_neonatal) %>%
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value") %>% 
  dplyr::mutate(`Observation status` = case_when(
    Neonatal_period == "Early_neonatal_rate" ~ obs_status_early,
    Neonatal_period == "Late_neonatal_rate" ~ obs_status_late,
    Neonatal_period == "Neonatal_rate" ~ obs_status_neonatal)) %>% 
  select(-c(obs_status_early, obs_status_late, obs_status_neonatal))

clean_csv_data_country_of_birth <- data_in_csv_format %>%
  dplyr::filter(mother_country != "Total") %>% 
  dplyr::mutate(Neonatal_period = gsub("_rate", "", Neonatal_period),
                Neonatal_period = gsub("_", " ", Neonatal_period),
                Neonatal_period = ifelse(Neonatal_period == "Neonatal", "", Neonatal_period),
                mother_country = case_when(
                  mother_country == "Total outside the United Kingdom" ~ "Not born in UK",
                  mother_country == "The Americas and the Caribbean" ~ "Born in the Americas or the Caribbean",
                  mother_country == "Other/Not stated" ~ "Other/Not stated",
                  TRUE ~ paste0("Born in ", mother_country)
                ),
                # mother_country = str_replace(mother_country, "and", "or"),
                mother_country = str_replace(mother_country, "United Kingdom", "UK")) %>% 
  dplyr::rename(`Neonatal period` = Neonatal_period,
                `Country of birth` = mother_country) %>%
  dplyr::mutate(Year = year,
                Sex = "",
                Country = country,
                Birthweight = "",
                Age = "",
                GeoCode = "",
                Region = "")  %>% 
  dplyr::mutate(Value = as.numeric(Value)) 


SDGupdater::multiple_year_warning(filename, country_of_birth_tab_name,"country_of_birth")
SDGupdater::multiple_country_warning(filename, country_of_birth_tab_name,"country_of_birth")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(clean_data,
   data_for_calculations, data_in_csv_format,
   info_cells, 
   tidy_data,
   country, year,
   number_of_rate_calculation_mismatches)

