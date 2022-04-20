# date: 13/04/2022
# automation for 3-2-2 for data published from 2022 onward

header_row <- first_header_row_area_of_residence

# read in data -----------------------------------------------------------------

if (header_row == 1) {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = area_of_residence_tab_name, 
                                     colNames = TRUE)  
} else {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = area_of_residence_tab_name, 
                                     colNames = FALSE, skipEmptyRows = FALSE) 
}

# clean the columns that contain strings ---------------------------------------

clean_data <- source_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))


# separate the data from the above-table metadata ------------------------------

if (header_row > 1) {
  data_no_headers <- clean_data[(header_row + 1):nrow(clean_data), ]
  
  # only use the following if you need the country and year info contained above the headers 
  # (it may be useful to put the details the are output in the QA file)
  metadata <- get_info_cells(clean_data, header_row, "xlsx")
  year <- unique_to_string(metadata$Year) # only if year is expected in the info above the header
  country <- unique_to_string(metadata$Country) # only if country is expected in the info above the header

}

# clean the column names -------------------------------------------------------

if (header_row > 1){
  with_headers <- data_no_headers
  names(with_headers) <- clean_data[header_row, ]

  # if you import a csv, numbers will now be read as characters - you can rectify this here
  # NOTE: check that data types are what you expect after running this!
  main_data <-  with_headers %>% 
    type.convert(as.is = TRUE) 
  
} else {
  main_data <- clean_data 
  names(main_data) <- SDGupdater::remove_superscripts(names(main_data)) 
  
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
  dplyr::mutate(Year = year,
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



