# Author: Emma Wood
# Date (start): 29/01/2021
# Purpose: To create csv data for country of occurrence: baby sex disaggregations for indicator 3.2.2
# Requirements:This script is called by compile_tables.R, which is called by update_indicator_main.R


country_of_occurrence_by_sex <- dplyr::filter(source_data, sheet == country_of_occurrence_by_sex_tab_name)


info_cells <- SDGupdater::get_info_cells(country_of_occurrence_by_sex, first_header_row_country_by_sex)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- country_of_occurrence_by_sex %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  SDGupdater::remove_blanks_and_info_cells(first_header_row_country_by_sex) %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

if(year < 2015) {
  tidy_data <- main_data %>%
    unpivotr::behead("left-up", country) %>%
    unpivotr::behead("left", sex) %>%
    unpivotr::behead("up-left", measure) %>%
    unpivotr::behead("up-left", rate_type) %>%
    unpivotr::behead("up-left", life_event_age) %>%
    unpivotr::behead("up", baby_age) %>%
    dplyr::select(country, sex, measure, rate_type, life_event_age, baby_age,
                  numeric)
} else {
  tidy_data <- main_data %>%
    unpivotr::behead("left-up", area_code) %>%
    unpivotr::behead("left-up", country) %>%
    unpivotr::behead("left", sex) %>%
    unpivotr::behead("up-left", measure) %>%
    unpivotr::behead("up-left", rate_type) %>%
    unpivotr::behead("up-left", life_event_age) %>%
    unpivotr::behead("up", baby_age) %>%
    dplyr::select(area_code, country, sex, measure, rate_type, life_event_age, baby_age,
                  numeric)
}


clean_data <- tidy_data %>%
  dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
  dplyr::mutate(country = trimws(country,  which = "both"),
         sex = trimws(sex,  which = "both"))

data_for_calculations <- clean_data %>%
  tidyr::pivot_wider(names_from = c(measure, rate_type, life_event_age, baby_age),
              values_from = numeric)

# TO DO: turn this into a function for finding columns whose names may change slightly
neonatal_rate_patterns <- c("Rates", "1,000", "Neonatal")
early_neonatal_rate_patterns <- c("Rates", "1,000", "Early")
early_neonatal_number_patterns <- c("Numbers", "Deaths", "Early")
neonatal_number_patterns <- c("Numbers", "Deaths", "Neo") # if the publication starts putting 'neonatal' in the same cell as 'early' and 'late', this might need editing

neonatal_rate_column <- which(apply(sapply(neonatal_rate_patterns, grepl, 
                                     names(data_for_calculations)), 1, all) == TRUE)
early_neonatal_rate_column <- which(apply(sapply(early_neonatal_rate_patterns, grepl, 
                                           names(data_for_calculations)), 1, all) == TRUE)
early_neonatal_number_column <- which(apply(sapply(early_neonatal_number_patterns, grepl, 
                                                 names(data_for_calculations)), 1, all) == TRUE)
neonatal_number_column <- which(apply(sapply(neonatal_number_patterns, grepl, 
                                                   names(data_for_calculations)), 1, all) == TRUE)

names(data_for_calculations)[neonatal_rate_column] <- "neonatal_rate"
names(data_for_calculations)[early_neonatal_rate_column] <- "early_neonatal_rate"
names(data_for_calculations)[early_neonatal_number_column] <- "early_neonatal_number"
names(data_for_calculations)[neonatal_number_column] <- "neonatal_number"

calculation <- data_for_calculations %>%
  dplyr::mutate(late_neonatal_number = neonatal_number - early_neonatal_number) %>% 
  dplyr::mutate(late_neonatal_rate = ifelse(late_neonatal_number > 3,
                                            neonatal_rate - early_neonatal_rate, NA)) %>% 
  dplyr::mutate(obs_status_early = case_when(
    early_neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
    early_neonatal_number >= 3 & early_neonatal_number <= 19 ~ "Low reliability",
    early_neonatal_number > 19  ~ "Normal value"),
    obs_status_late = case_when(
      late_neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
      late_neonatal_number >= 3 & late_neonatal_number <= 19 ~ "Low reliability",
      late_neonatal_number > 19  ~ "Normal value"),
    obs_status_neonatal = case_when(
      neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
      neonatal_number >= 3 & neonatal_number <= 19 ~ "Low reliability",
      neonatal_number > 19  ~ "Normal value"))

if(year < 2015) {
  relevant_columns <- calculation %>%
    dplyr::select(country, sex, 
                  early_neonatal_rate, late_neonatal_rate, neonatal_rate,
                  obs_status_early, obs_status_late, obs_status_neonatal)
} else {
  relevant_columns <- calculation %>%
    dplyr::select(country, sex, area_code,
                  early_neonatal_rate, late_neonatal_rate, neonatal_rate,
                  obs_status_early, obs_status_late, obs_status_neonatal)
}

data_in_csv_format <- relevant_columns %>%
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value") %>%
  dplyr::mutate(`Observation status` = case_when(
    Neonatal_period == "early_neonatal_rate" ~ obs_status_early,
    Neonatal_period == "late_neonatal_rate" ~ obs_status_late,
    Neonatal_period == "neonatal_rate" ~ obs_status_neonatal)) %>% 
  select(-c(obs_status_early, obs_status_late, obs_status_neonatal))

clean_csv_data_country_by_sex <- data_in_csv_format %>%
  dplyr::mutate(Neonatal_period = dplyr::case_when(
    Neonatal_period == "early_neonatal_rate" ~ "Early neonatal",
    Neonatal_period == "late_neonatal_rate" ~ "Late neonatal",
    Neonatal_period == "neonatal_rate" ~ ""),
    sex = ifelse(sex == "All", "", sex)) %>%
  dplyr::rename(`Neonatal period` = Neonatal_period,
         Sex = sex,
         Country = country) %>%
  dplyr::mutate(Year = year,
         Birthweight = "",
         Age = "",
         Region = "",
         `Country of birth` =  "",
         Country = ifelse(Country == "United Kingdom", "", Country),
         Sex = dplyr::case_when(
           Sex == "P" ~ "",
           Sex == "M" ~ "Male",
           Sex == "F" ~ "Female",
           TRUE ~ Sex))

if(year >= 2015){
  clean_csv_data_country_by_sex <- clean_csv_data_country_by_sex %>% 
    dplyr::rename(GeoCode = area_code) %>% 
    dplyr::mutate(GeoCode = ifelse(Country == "England and Wales", "K04000001", GeoCode))
} else {
  clean_csv_data_country_by_sex <- clean_csv_data_country_by_sex %>% 
    dplyr::mutate(GeoCode = "")
}

SDGupdater::multiple_year_warning(filename, country_of_occurrence_by_sex_tab_name,"country of occurrence by sex")
SDGupdater::multiple_country_warning(filename, country_of_occurrence_by_sex_tab_name,"country of occurrence by sex")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(clean_data,
   data_for_calculations, data_in_csv_format,
   info_cells, 
   tidy_data, relevant_columns, 
   neonatal_rate_column, early_neonatal_rate_column,
   country, year)


