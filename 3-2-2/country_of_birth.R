# Author: Emma Wood
# Date (start): 26/01/2021
# Purpose: To create csv data for country of birth for indicator 3.2.2
# Requirements: This script is called by compile_tables.R, which is called by update_indicator_main.R


country_of_birth <- dplyr::filter(source_data, sheet == country_of_birth_tab_name)

info_cells <- SDGupdater::get_info_cells(country_of_birth, first_header_row_country_of_birth)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- country_of_birth %>%
  SDGupdater::remove_blanks_and_info_cells(first_header_row_country_of_birth) %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

tidy_data <- main_data %>%
  unpivotr::behead("left-up", birthweight) %>%
  unpivotr::behead("left", mother_country) %>%
  unpivotr::behead("up-left", measure) %>%
  unpivotr::behead("up-left", event) %>%
  unpivotr::behead("up", baby_age) %>%
  dplyr::select(birthweight, mother_country, measure, event, baby_age,
                numeric, local_format_id) %>% 
  dplyr::mutate(across(where(is.character), ~ str_squish(.)))

bold_countries <- tidy_data %>% 
  dplyr::filter((mother_country == "Africa" &
                  birthweight == "All")|
                  (mother_country == "United Kingdom" &
                  birthweight == "All") ) %>% 
  dplyr::distinct(local_format_id) %>% 
  pull(local_format_id)

countries_to_keep <- tidy_data %>% 
  filter(local_format_id %in% bold_countries &
           birthweight == "All") %>% 
  distinct(mother_country, birthweight)
# have done it this way because sometimes the number is in a different format to 
# the cell containing the country name, 
# and if we just did the filter without then doing the left_join (below) we would 
# lose those number rows

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

