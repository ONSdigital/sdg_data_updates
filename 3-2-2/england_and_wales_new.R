# Author: Emma Wood
# Date (start): 13/04/2022
# Purpose: To create csv data for country of occurrence, where country is 
# England and Wales (this figure is available in country of occurrence by sex 
# before 2018)

# automation for 3-2-2 for data published from 2022 onward

source_data <- get_type1_data(header_row = first_header_row_england_and_wales,
                              filename = filename,
                              tabname = england_and_wales_timeseries_tab_name)

clean_data <- suppressWarnings(clean_strings(source_data))
metadata <- extract_metadata(clean_data, first_header_row_england_and_wales)
main_data <- extract_data(clean_data, first_header_row_england_and_wales)

if (first_header_row_england_and_wales > 1){
  main_data <- type.convert(main_data, as.is = TRUE) 
}

main_data <- janitor::clean_names(main_data)

# make column names consistent across years ------------------------------------

renamed_main <- main_data %>% 
  rename_column(primary = c("rate", "neo"), 
                not_pattern = "peri|post|early|late|stillbirth",
                new_name = "neonatal_rate") %>% 
  rename_column(primary = c("rate","neo", "early", "7"),
                not_pattern = "peri|post|late|stillbirth",
                new_name = "early_neonatal_rate") %>% 
  rename_column(primary = c("rate","neo", "late"),
                not_pattern = "peri|post|early|stillbirth",
                new_name = "late_neonatal_rate") %>% 
  
  rename_column(primary = c("neo"), 
                not_pattern = "peri|post|early|late|stillbirth|rate",
                new_name = "neonatal_number") %>% 
  rename_column(primary = c("neo", "early", "7"),
                not_pattern = "peri|post|late|stillbirth|rate",
                new_name = "early_neonatal_number") %>% 
  rename_column(primary = c("neo", "late"),
                not_pattern = "peri|post|early|stillbirth|rate",
                new_name = "late_neonatal_number") 

#-------------------------------------------------------------------------------

calculations <- renamed_main %>% 
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
      neonatal_number > 19  ~ "Normal value")) %>% 
  dplyr::filter(year == unique(bound_tables$Year)[1])

data_in_csv_format <- calculations %>% 
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
                Country = metadata$country,
                `Country of birth` =  "",
                Year = as.character(Year))

year <- metadata$year
country <- metadata$country
SDGupdater::multiple_year_warning(filename, england_and_wales_timeseries_tab_name,"birthweight by age")
SDGupdater::multiple_country_warning(filename, england_and_wales_timeseries_tab_name,"birthweight by age")

# clean environment ------------------------------------------------------------
rm(source_data, clean_data, metadata,
   renamed_main, calculations, data_in_csv_format,
   year, country)
  