# date: 20/04/2022
# automation for 3-2-2 for data published from 2022 onward
# birth weight and mother age disaggregations


source_data <- get_type1_data(header_row = first_header_row_country_by_sex,
                              filename = filename,
                              tabname = country_of_occurrence_by_sex_tab_name)

clean_data <- clean_strings(source_data)
metadata <- extract_metadata(clean_data, first_header_row_area_of_residence)
main_data <- extract_data(clean_data, first_header_row_area_of_residence)

if (first_header_row_country_by_sex > 1){
  main_data <- type.convert(main_data, as.is = TRUE) 
}

main_data <- clean_names(main_data) %>% 
  janitor::remove_empty(which = "rows")

# make column names consistent across years ------------------------------------

renamed_main <- main_data %>% 
  rename_column(primary = c("rate", "neo"), 
                not_pattern = "peri|post|early",
                new_name = "neonatal_rate") %>% 
  rename_column(primary = c("early", "rate", "neo"), 
                not_pattern = "peri|post",
                new_name = "early_neonatal_rate") %>% 
  rename_column(primary = c("live", "birth"), 
                new_name = "number_live_births") %>% 
  rename_column(primary = c("early", "neo", "death"),
                not_pattern = "rate|post|peri",
                new_name = "early_neonatal_number") %>% 
  rename_column(primary = c("neo", "death"),
                not_pattern = "rate|post|peri|early",
                new_name = "neonatal_number") %>% 
  rename_column(primary = "country",
                new_name = "country_of_occurrence")

# calculate late neonatal rates-------------------------------------------------

clean_numeric_columns <- renamed_main %>% 
  mutate(neonatal_number = remove_symbols(neonatal_number),
         early_neonatal_number = remove_symbols(early_neonatal_number),
         early_neonatal_rate = remove_symbols(early_neonatal_rate),
         number_live_births = remove_symbols(number_live_births),
         neonatal_rate = remove_symbols(neonatal_rate)) 

calculations <- clean_numeric_columns %>%
  dplyr::mutate(number_late_neonatal_deaths = neonatal_number - early_neonatal_number) %>% 
  # Northern Ireland calculation is different because rates are calculated based 
  # on the same numerator and denominator populations, but number of births
  # and number of deaths use different populations (they treat non-residents differently)
  dplyr::mutate(late_neonatal_rate = case_when(
    grepl("orthern", country) == TRUE ~ ifelse(number_late_neonatal_deaths >= 3,
                                           neonatal_rate - early_neonatal_rate, NA),
    grepl("orthern", country) == FALSE ~  SDGupdater::calculate_valid_rates_per_1000(number_late_neonatal_deaths,
                                                                                     number_live_births, decimal_places))
    ) %>% 
  dplyr::mutate(obs_status_early = case_when(
    early_neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
    early_neonatal_number >= 3 & early_neonatal_number <= 19 ~ "Low reliability",
    early_neonatal_number > 19  ~ "Normal value"),
    obs_status_late = case_when(
      number_late_neonatal_deaths < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
      number_late_neonatal_deaths >= 3 & number_late_neonatal_deaths <= 19 ~ "Low reliability",
      number_late_neonatal_deaths > 19  ~ "Normal value"),
    obs_status_neonatal = case_when(
      neonatal_number < 3 | is.na(early_neonatal_number) ~ "Missing value; suppressed", 
      neonatal_number >= 3 & neonatal_number <= 19 ~ "Low reliability",
      neonatal_number > 19  ~ "Normal value"))


data_in_csv_format <- calculations %>%
    dplyr::select(country_of_occurrence, sex, area_code,
                  early_neonatal_rate, late_neonatal_rate, neonatal_rate,
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

clean_csv_data_country_by_sex <- data_in_csv_format %>%
  dplyr::mutate(Neonatal_period = dplyr::case_when(
    Neonatal_period == "early_neonatal_rate" ~ "Early neonatal",
    Neonatal_period == "late_neonatal_rate" ~ "Late neonatal",
    Neonatal_period == "neonatal_rate" ~ ""),
    sex = ifelse(sex == "All", "", sex)) %>%
  dplyr::rename(`Neonatal period` = Neonatal_period,
         Sex = sex,
         Country = country_of_occurrence) %>%
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

clean_csv_data_country_by_sex <- clean_csv_data_country_by_sex %>% 
    dplyr::rename(GeoCode = area_code) %>% 
    dplyr::mutate(GeoCode = ifelse(Country == "England and Wales", "K04000001", GeoCode))


SDGupdater::multiple_year_warning(filename, country_of_occurrence_by_sex_tab_name,"country of occurrence by sex")
SDGupdater::multiple_country_warning(filename, country_of_occurrence_by_sex_tab_name,"country of occurrence by sex")

# put the column names in sentence case
names(clean_csv_data_birtweight_by_mum_age) <- 
  str_to_sentence(names(clean_csv_data_birtweight_by_mum_age))

# clean environment ------------------------------------------------------------
rm(source_data, clean_data, main_data, renamed_main, data_in_csv_format,
   calculations)

if (header_row > 1) {
  rm(
    data_no_headers,
    metadata,
    year,
    country,
    with_headers
  )
}


