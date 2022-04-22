# date: 13/04/2022
# automation for 3-2-2 for data published from 2022 onward

source_data <- get_data(header_row = first_header_row_area_of_residence,
                        filename = filename,
                        tabname = area_of_residence_tab_name)
 
clean_data <- clean_strings(source_data)
metadata <- extract_metadata(clean_data, first_header_row_area_of_residence)
main_data <- extract_data(clean_data, first_header_row_area_of_residence)

if (header_row > 1){
  main_data <- type.convert(main_data, as.is = TRUE) 
}

main_data <- clean_names(main_data)

# make column names consistent across years ------------------------------------

renamed_main <- main_data %>% 
  rename_column(primary = c("rate", "neo"), 
                not_pattern = "peri|post",
                new_name = "neonatal_rate") %>% 
  rename_column(primary = c("live", "birth"), 
                new_name = "number_live_births") %>% 
  rename_column(primary = c("neo", "death"),
                not_pattern = "rate|post|peri",
                new_name = "number_neonatal_deaths") %>% 
  rename_column(primary = "code",
                new_name = "GeoCode") %>% 
  rename_column(primary = c("area", "name"),
                new_name = "Region") %>% 
  rename_column(primary = "geography",
                new_name = "geography")

#-------------------------------------------------------------------------------

calculations_region <- renamed_main %>%
  dplyr::mutate(obs_status_neonatal = case_when(
    number_neonatal_deaths < 3 | is.na(number_neonatal_deaths) ~ "Missing value; suppressed", 
    number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
    number_neonatal_deaths > 19  ~ "Normal value"))

# remove welsh health boards and local authorities 
# due to high incidence of low reliability
lower_geography_removed <- calculations_region %>% 
  dplyr::filter(geography %in% c("Region", "region",
                          "Country", "country") &
           # remove'outside of England and wales' entries
           grepl("J99000001", GeoCode) == FALSE) 

data_in_csv_format <- lower_geography_removed %>%
  dplyr::select(GeoCode, Region, geography,
                neonatal_rate,
                obs_status_neonatal) 

# finalise csv -----------------------------------------------------------------

clean_csv_data_area_of_residence <- data_in_csv_format %>%
  dplyr::rename(Value = neonatal_rate,
                `Observation status` = obs_status_neonatal) %>%
  # suppressed data may be indicatoed by a colon, which prevents the column from 
  # being numeric. Needsremoving so that we can control the number of decimal places
  dplyr::mutate(Value = ifelse(Value == ":", NA, as.numeric(Value))) %>%
  dplyr::mutate(Year = metadata$year,
                Sex = "",
                `Neonatal period` = "",
                Birthweight = "",
                Age = "",
                `Country of birth` = "", 
                Country = "England",
                Region = SDGupdater::format_region_names(Region))

# put the column names in sentence case
names(clean_csv_data_area_of_residence) <- 
  str_to_sentence(names(clean_csv_data_area_of_residence))

# clean environment ------------------------------------------------------------
rm(source_data, clean_data, main_data, renamed_main, data_in_csv_format)

if (first_header_row_area_of_residence > 1) {
  rm(
    data_no_headers,
    metadata,
    year,
    country,
    with_headers
    )
}
