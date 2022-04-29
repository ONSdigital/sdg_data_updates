# Author: Emma Wood
# Date (start): 26/01/2021
# Purpose: To create csv data for birthweight by mother age disaggregation for indicator 3.2.2
# Requirements: This script is called by compile_tables.R, which is called by update_indicator_main.R


birthweight_by_mum_age <- dplyr::filter(source_data, sheet == birthweight_by_mum_age_tab_name)

info_cells <- SDGupdater::get_info_cells(birthweight_by_mum_age, first_header_row_birthweight_by_mum_age)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- birthweight_by_mum_age %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  SDGupdater::remove_blanks_and_info_cells(first_header_row_birthweight_by_mum_age) %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

tidy_data <- main_data %>%
  unpivotr::behead("left-up", birthweight) %>%
  unpivotr::behead("left", mother_age) %>%
  unpivotr::behead("up-left", measure) %>%
  unpivotr::behead("up-left", event) %>%
  unpivotr::behead("up-left", baby_age) %>%
  dplyr::select(birthweight, mother_age, measure, event, baby_age,
         numeric)

clean_data <- tidy_data %>%
  dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
  dplyr::mutate(birthweight = trimws(birthweight,  which = "both"),
                mother_age = trimws(mother_age, which = "both")) %>%
  dplyr::mutate(birthweight = ifelse(birthweight == "4000 and" | birthweight == "over",
                              "4000 and over", birthweight))

data_for_calculations <- clean_data %>%
  tidyr::pivot_wider(names_from = c(measure, baby_age, event),
              values_from = numeric)

# rename columns so they are the same each year --------------------------------
data_for_calculations <- data_for_calculations %>% 
  rename_column(primary = c("Rates", "Neo"),
                new_name = "Neonatal_rate") %>% 
  rename_column(primary = c("Live"),
                new_name = "number_live_births") %>% 
  rename_column(primary = c("Numbers", "Early"),
                new_name = "number_early_neonatal_deaths") %>% 
  rename_column(primary = c("Numbers", "Neo", "Deaths"),
                new_name = "number_neonatal_deaths")
#-------------------------------------------------------------------------------


calculations_weight_age <- data_for_calculations %>%
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
      number_late_neonatal_deaths < 3 | is.na(number_late_neonatal_deaths) ~ "Missing value; suppressed", 
      number_late_neonatal_deaths >= 3 & number_late_neonatal_deaths <= 19 ~ "Low reliability",
      number_late_neonatal_deaths > 19  ~ "Normal value"),
    obs_status_neonatal = case_when(
      number_neonatal_deaths < 3 | is.na(number_neonatal_deaths) ~ "Missing value; suppressed", 
      number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
      number_neonatal_deaths > 19  ~ "Normal value"))

rate_mismatches_weight_age <- SDGupdater::count_mismatches(
  calculations_weight_age$Rates_Neonatal_check, calculations_weight_age$Neonatal_rate)


data_in_csv_format <- calculations_weight_age %>%
  dplyr::select(birthweight, mother_age,
                Early_neonatal_rate, Late_neonatal_rate, Neonatal_rate,
                obs_status_early, obs_status_late, obs_status_neonatal) %>%
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value") %>% 
  dplyr::mutate(`Observation status` = case_when(
    Neonatal_period == "Early_neonatal_rate" ~ obs_status_early,
    Neonatal_period == "Late_neonatal_rate" ~ obs_status_late,
    Neonatal_period == "Neonatal_rate" ~ obs_status_neonatal
  )) %>% 
  select(-c(obs_status_early, obs_status_late, obs_status_neonatal))

clean_csv_data_birtweight_by_mum_age <- data_in_csv_format %>%
  dplyr::mutate(Neonatal_period = gsub("_rate", "", Neonatal_period),
         Neonatal_period = gsub("_", " ", Neonatal_period),
         Neonatal_period = ifelse(Neonatal_period == "Neonatal", "", Neonatal_period),
         mother_age = gsub("-", " to ", mother_age),
         mother_age = gsub("&", " and ", mother_age),
         mother_age = gsub("<", "Less than ", mother_age),
         mother_age = ifelse(mother_age == "Notstated", "Not stated", mother_age),
         mother_age = ifelse(mother_age == "All", "", mother_age),
         mother_age = trimws(mother_age,  which = "both"),
         birthweight = gsub("-", " to ", birthweight),
         birthweight = gsub("<", "Under ", birthweight),
         birthweight = ifelse(birthweight == "Notstated", "Not stated", birthweight),
         birthweight = ifelse(birthweight == "All", "", birthweight),
         Country = country,
         GeoCode = ifelse(country == "England and Wales", "K04000001", "")) %>%
  dplyr::mutate(mother_age = ifelse(mother_age == "Less than 20", "19 and under", mother_age),
                mother_age = ifelse(mother_age == "40  and  over", "40 and over", mother_age)) %>% 
  dplyr::rename(`Neonatal period` = Neonatal_period,
         Age = mother_age,
         Birthweight = birthweight) %>%
  dplyr::mutate(Year = year,
         Sex = "",
         Region = "",
         `Country of birth` = "")  %>% 
  dplyr::mutate(Value = as.numeric(Value)) %>% 
  dplyr::filter(Birthweight != "Unlinked deaths") %>% 
  # because the England and Wales figure for birthweight is different to that for country of occurrence (linked deaths vs all deaths)
  dplyr::mutate(England_Wales_headline = ifelse(Birthweight == "" & Age == "", TRUE, FALSE)) %>% 
  dplyr::filter(England_Wales_headline == FALSE) %>% 
  dplyr::select(-England_Wales_headline)


SDGupdater::multiple_year_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")
SDGupdater::multiple_country_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(clean_data,
   data_for_calculations, data_in_csv_format,
   info_cells, 
   tidy_data,
   country, year)

