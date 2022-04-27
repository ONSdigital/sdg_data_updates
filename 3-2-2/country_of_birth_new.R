# date: 20/04/2022
# automation for 3-2-2 for data published from 2022 onward
# birth weight and mother age disaggregations

source_data <- get_type1_data(header_row = first_header_row_country_of_birth,
                        filename = filename,
                        tabname = country_of_birth_tab_name)

clean_data <- suppressWarnings(clean_strings(source_data))
metadata <- extract_metadata(clean_data, first_header_row_country_of_birth)
main_data <- extract_data(clean_data, first_header_row_country_of_birth)

if (first_header_row_country_of_birth > 1){
  main_data <- type.convert(main_data, as.is = TRUE) 
}

main_data <- clean_names(main_data) %>% 
  janitor::remove_empty(which = "rows")

# make column names consistent across years ------------------------------------

renamed_main <- main_data %>% 
  rename_column(primary = c("rate", "neo"), 
                not_pattern = "peri|post|early",
                new_name = "Neonatal_rate") %>% 
  
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
  
  rename_column(primary = c("mother", "country"),
                new_name = "mother_country") 


# calculate late neonatal rates ------------------------------------------------
clean_numeric_columns <- renamed_main %>% 
   mutate(number_neonatal_deaths = suppressWarnings(remove_symbols(number_neonatal_deaths)),
         number_early_neonatal_deaths = suppressWarnings(remove_symbols(number_early_neonatal_deaths)),
         number_live_births =  suppressWarnings(remove_symbols(number_live_births)),
         Neonatal_rate = suppressWarnings(remove_symbols(Neonatal_rate)))
         
calculations_country_of_birth <- clean_numeric_columns %>%
  dplyr::mutate(number_late_neonatal_deaths = 
                  number_neonatal_deaths - number_early_neonatal_deaths) %>%
  dplyr::mutate(Late_neonatal_rate = 
                  SDGupdater::calculate_valid_rates_per_1000(number_late_neonatal_deaths,
                                                             number_live_births, 
                                                             decimal_places),
                Early_neonatal_rate = 
                  SDGupdater::calculate_valid_rates_per_1000(number_early_neonatal_deaths,
                                                             number_live_births, 
                                                             decimal_places),
                # overall neonatal rates are calculated already in the download, so we can check our calcs against these
                Rates_Neonatal_check = 
                  SDGupdater::calculate_valid_rates_per_1000(number_neonatal_deaths,
                                                             number_live_births, 
                                                             decimal_places)) 
rate_mismatches_country_of_birth <- SDGupdater::count_mismatches(
  calculations_country_of_birth$Rates_Neonatal_check, 
  calculations_country_of_birth$Neonatal_rate)

observation_status <- calculations_country_of_birth %>% 
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

birthweight_removed <- observation_status %>% 
  mutate(keep = grepl("all", tolower(birthweight))) %>% 
  filter(keep == TRUE) %>% 
  select(-keep)

data_in_csv_format <- birthweight_removed %>%
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

low_level_country_of_birth <- c("Scotland",
                                "England and Wales",
                                "Northern Ireland",
                                "New EU",
                                "Irish Republic",
                                "North Africa",
                                "Western Africa",
                                "Central Africa",
                                "Eastern Africa",
                                "Southern Africa",
                                "North America and Central America",
                                "South America",
                                "Caribbean",
                                "Middle East and Central Asia",
                                "Eastern Asia",
                                "Southern Asia",
                                "India",
                                "Pakistan",
                                "Bangladesh",
                                "South East Asia")

clean_csv_data_country_of_birth <- data_in_csv_format %>%
  dplyr::filter(mother_country != "Total" &
                  mother_country %not_in% low_level_country_of_birth) %>% 
  dplyr::mutate(Neonatal_period = gsub("_rate", "", Neonatal_period),
                Neonatal_period = gsub("_", " ", Neonatal_period),
                Neonatal_period = ifelse(Neonatal_period == "Neonatal", "", Neonatal_period),
                mother_country = case_when(
                  mother_country == "Total outside the United Kingdom" ~ "Not born in UK",
                  mother_country == "The Americas and the Caribbean" ~ "Born in the Americas and the Caribbean",
                  mother_country == "United Kingdom, Isle of Man and Channel Islands" ~ "Born in UK, Isle of Man and Channel Islands",
                  mother_country == "Other/Not stated" ~ "Other/Not stated",
                  TRUE ~ paste0("Born in ", mother_country)
                ),
                # mother_country = str_replace(mother_country, "and", "or"),
                mother_country = str_replace(mother_country, "United Kingdom", "UK")) %>% 
  dplyr::rename(`Neonatal period` = Neonatal_period,
                `Country of birth` = mother_country) %>%
  dplyr::mutate(Year = metadata$year,
                Sex = "",
                Country = metadata$country,
                Birthweight = "",
                Age = "",
                GeoCode = "",
                Region = "")  %>% 
  dplyr::mutate(Value = as.numeric(Value)) 

year <- metadata$year
SDGupdater::multiple_year_warning(filename, country_of_birth_tab_name,"country_of_birth")
country <- metadata$country
SDGupdater::multiple_country_warning(filename, country_of_birth_tab_name,"country_of_birth")

# clean environment ------------------------------------------------------------
rm(source_data, clean_data, main_data, renamed_main, data_in_csv_format,
   metadata,
   year,
   country)

