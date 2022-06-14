# Author: Emma Wood
# Date (start): 25/10/2021
# Purpose: To create csv data for country of occurrence, where country is 
# England and Wales (this figure is available in country of occurrence by sex 
# before 2018)

england_and_wales <- dplyr::filter(source_data, sheet == england_and_wales_timeseries_tab_name)

info_cells <- SDGupdater::get_info_cells(england_and_wales, first_header_row_england_and_wales)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- england_and_wales %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  SDGupdater::remove_blanks_and_info_cells(first_header_row_country_by_sex) %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

tidy_data <- main_data %>%
  unpivotr::behead("left", year) %>%
  unpivotr::behead("up-left", measure) %>%
  unpivotr::behead("up-left", rate_type) %>%
  unpivotr::behead("up-left", life_event_age) %>%
  unpivotr::behead("up", baby_age) %>%
  dplyr::select(year, measure, rate_type, life_event_age, baby_age,
                numeric)

clean_data <- tidy_data %>%
  dplyr::filter(!is.na(numeric)) # to remove cells that are just ends of a header that have run on to the next row

data_for_calculations <- clean_data %>% 
  tidyr::pivot_wider(names_from = c(measure, rate_type, life_event_age, baby_age),
                     values_from = numeric) 

#-------------------------------------------------------------------------------

data_for_calculations <- data_for_calculations %>% 
  rename_column(primary = c("Rates", "1,000", "Neonatal", "28 days"),
                new_name = "neonatal_rate") %>% 
  rename_columns(primary = c("Rates", "1,000", "Early", "7 days"),
                 new_name = "early_neonatal_rate") %>% 
  rename_columns(primary = c("Rates", "Late", "neonatal"),
                 new_name =  "late_neonatal_rate") %>% 

  rename_columns(primary = c("NA", "Neonatal", "28 days"),
                 new_name =  "neonatal_number") %>% 
  rename_columns(primary = c("NA", "Early", "7 days"),
                 new_name =  "early_neonatal_number") %>%
  rename_columns(primary = c("NA", "Late", "neonatal"),
                 new_name =  "late_neonatal_number")

# 
# 
# data_for_calculations <- name_columns(data_for_calculations, 
#                                       c("Births", "Live"),
#                                       "number_live_births")
#-------------------------------------------------------------------------------

calculation_england_and_wales <- data_for_calculations %>% 
  dplyr::mutate(obs_status_early = case_when(
    early_neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
    early_neonatal_number >= 3 & early_neonatal_number <= 19 ~ "Low reliability",
    early_neonatal_number > 19  ~ "Normal value"),
    obs_status_late = case_when(
      late_neonatal_number < 3 | is.na(late_neonatal_number) ~ "Missing value; suppressed", 
      late_neonatal_number >= 3 & late_neonatal_number <= 19 ~ "Low reliability",
      late_neonatal_number > 19  ~ "Normal value"),
    obs_status_neonatal = case_when(
      neonatal_number < 3 | is.na(neonatal_number) ~ "Missing value; suppressed", 
      neonatal_number >= 3 & neonatal_number <= 19 ~ "Low reliability",
      neonatal_number > 19  ~ "Normal value")) %>% 
  dplyr::filter(year == unique(bound_tables$Year)[1])

data_in_csv_format <- calculation_england_and_wales %>% 
  dplyr::select(year, early_neonatal_rate, late_neonatal_rate, neonatal_rate,
                obs_status_early, obs_status_late, obs_status_neonatal) %>% 
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value") %>%
  dplyr::mutate(`Observation status` = case_when(
    Neonatal_period == "early_neonatal_rate" ~ obs_status_early,
    Neonatal_period == "late_neonatal_rate" ~ obs_status_late,
    Neonatal_period == "neonatal_rate" ~ obs_status_neonatal)) %>% 
  select(-c(obs_status_early, obs_status_late, obs_status_neonatal))

clean_csv_data_england_and_wales <- data_in_csv_format %>%
  dplyr::mutate(Neonatal_period = dplyr::case_when(
    Neonatal_period == "early_neonatal_rate" ~ "Early neonatal",
    Neonatal_period == "late_neonatal_rate" ~ "Late neonatal",
    Neonatal_period == "neonatal_rate" ~ "")) %>%
  dplyr::rename(`Neonatal period` = Neonatal_period,
                Year = year) %>%
  dplyr::mutate(Birthweight = "",
                Age = "",
                Region = "",
                Sex = "",
                Country = country,
                `Country of birth` =  "")
  