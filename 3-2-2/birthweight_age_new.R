# date: 20/04/2022
# automation for 3-2-2 for data published from 2022 onward
# birth weight and mother age disaggregations

source_data <- get_type1_data(header_row = first_header_row_birthweight_by_mum_age,
                              filename = filename,
                              tabname = birthweight_by_mum_age_tab_name)

clean_data <- suppressWarnings(clean_strings(source_data))
metadata <- extract_metadata(clean_data, first_header_row_birthweight_by_mum_age)
main_data <- extract_data(clean_data, first_header_row_country_of_birth)

if (first_header_row_birthweight_by_mum_age > 1){
  main_data <- type.convert(main_data, as.is = TRUE) 
}

main_data <- clean_names(main_data) %>% 
  janitor::remove_empty(which = "rows")

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

# calculate late neonatal rates-------------------------------------------------

clean_numeric_columns <- renamed_main %>% 
  mutate(number_neonatal_deaths = remove_symbols(number_neonatal_deaths),
         number_early_neonatal_deaths = remove_symbols(number_early_neonatal_deaths),
         number_live_births = remove_symbols(number_live_births),
         neonatal_rate = remove_symbols(neonatal_rate)) 

calculations <- clean_numeric_columns %>%
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
  round(calculations$Rates_Neonatal_check, decimal_places), 
  round(calculations$neonatal_rate, decimal_places))

data_in_csv_format <- calculations %>%
  dplyr::select(birthweight, mother_age,
                Early_neonatal_rate, Late_neonatal_rate, neonatal_rate,
                obs_status_early, obs_status_late, obs_status_neonatal) %>%
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value") %>% 
  dplyr::mutate(`Observation status` = case_when(
    Neonatal_period == "Early_neonatal_rate" ~ obs_status_early,
    Neonatal_period == "Late_neonatal_rate" ~ obs_status_late,
    Neonatal_period == "neonatal_rate" ~ obs_status_neonatal
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
         Country = metadata$country,
         GeoCode = ifelse(Country == "England and Wales", "K04000001", "")) %>%
  dplyr::mutate(mother_age = ifelse(mother_age == "Less than 20", "19 and under", mother_age),
                mother_age = ifelse(mother_age == "40  and  over", "40 and over", mother_age)) %>% 
  dplyr::rename(`Neonatal period` = Neonatal_period,
         Age = mother_age,
         Birthweight = birthweight) %>%
  dplyr::mutate(Year = metadata$year,
         Sex = "",
         Region = "",
         `Country of birth` = "")  %>% 
  dplyr::mutate(Value = as.numeric(Value)) %>% 
  dplyr::filter(Birthweight != "Unlinked deaths") %>% 
  # because the England and Wales figure for birthweight is different to that for country of occurrence (linked deaths vs all deaths)
  dplyr::mutate(England_Wales_headline = ifelse(Birthweight == "" & Age == "", TRUE, FALSE)) %>% 
  dplyr::filter(England_Wales_headline == FALSE) %>% 
  dplyr::select(-England_Wales_headline)

year <- metadata$year
country <- metadata$country
SDGupdater::multiple_year_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")
SDGupdater::multiple_country_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")

# put the column names in sentence case
names(clean_csv_data_birtweight_by_mum_age) <- 
  str_to_sentence(names(clean_csv_data_birtweight_by_mum_age))

# clean environment ------------------------------------------------------------
rm(source_data, clean_data, main_data, renamed_main, data_in_csv_format,
   calculations, clean_numeric_columns,
    metadata,
    year,
    country
  )



