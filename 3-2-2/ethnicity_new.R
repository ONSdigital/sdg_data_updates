source_data <- get_type1_data(header_row = first_header_row_ethnicity,
                              filename = filename,
                              tabname = ethnicity_tab_name)

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
                new_name = "neonatal_rate") %>% 

  rename_column(primary = c("neo", "death"),
                not_pattern = "rate|post|peri|early",
                new_name = "number_neonatal_deaths")

# create csv -------------------------------------------------------------------

# data for Wales has low reliability so just select data for England, 
# and England and Wales

required_rates <- renamed_main %>% 
  filter(country != "Wales" & 
           tolower(ethnic_group) != "all" & 
           tolower(ethnic_group) != "unlinked deaths")

observation_status <- required_rates %>% 
  dplyr::mutate(
    obs_status_neonatal = case_when(
      number_neonatal_deaths < 3 | is.na(number_neonatal_deaths) ~ "Missing value; suppressed", 
      number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
      number_neonatal_deaths > 19  ~ "Normal value"))

clean_csv_data_ethnicity <- observation_status %>%
  dplyr::select(country, ethnic_group, 
                neonatal_rate,
                obs_status_neonatal) %>% 
  dplyr::rename(Country = country,
                Value = neonatal_rate,
                `Ethnic group` = ethnic_group,
                `Observation status` = obs_status_neonatal) %>%
  dplyr::mutate(Year = metadata$year,
                Sex = "",
                `Neonatal period` = "",
                Birthweight = "",
                Age = "",
                `Country of birth` = "", 
                Region = "",
                Value = as.numeric(Value))

year <- metadata$year
country <- metadata$country
SDGupdater::multiple_year_warning(filename, ethnicity_tab_name,"ethnicity")
SDGupdater::multiple_country_warning(filename, ethnicity_tab_name,"ethnicity")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(source_data, clean_data, main_data, renamed_main, 
   required_rates, observation_status,
   metadata,
   year,
   country
)



