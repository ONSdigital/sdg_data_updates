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
  mutate(across(where(is.character), tolower)) %>% 
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
                new_name = "Region")

#-------------------------------------------------------------------------------

calculations_region <- renamed_main %>%
  dplyr::mutate(obs_status_neonatal = case_when(
    number_neonatal_deaths < 3 | is.na(number_neonatal_deaths) ~ "Missing value; suppressed", 
    number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
    number_neonatal_deaths > 19  ~ "Normal value"))


data_in_csv_format <- calculations_region %>%
  dplyr::select(GeoCode, Region, 
                neonatal_rate,
                obs_status_neonatal) 

# done up to here.............................
# Need to get rid of the welsh health boards!







clean_csv_data_area_of_residence <- data_in_csv_format %>%
  dplyr::rename(Value = Neonatal_rate,
                `Observation status` = obs_status_neonatal) %>%
  dplyr::mutate(Year = year,
                Sex = "",
                `Neonatal period` = "",
                Birthweight = "",
                Age = "",
                `Country of birth` = "", 
                Country = "England",
                Region = SDGupdater::format_region_names(Region))

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# finalise csv -----------------------------------------------------------------

# make column names sentence case

# add extra columns for SDMX, rename levels of disaggregations, 
# put columns in correct order etc 

# order of disaggregations depend on order they appear. In some cases this won't 
# be alphanumeric order, so specify the order here and arrange by this fake column 
# instead of the real one
age_order <- data.frame(age = c("Under 66", "Over 65",  ""),
                        age_order = c(1:3))

csv_formatted <- tidy_data %>% 
  # rename columns that need renaming
  rename(`housing type` = type) %>%
  # Correct the names of levels of disaggregations, e.g total/UK will nearly always be replaced 
  # with a blank (""). Use case_when() if there are lots of options, or ifelse if there is just one
  mutate(age = 
           case_when(
             age == "all" ~ "",
             age == "< 66" ~ "Under 66",
             age == "> 65" ~ "Over 65",
             # this last line says 'for all other cases, keep Age the way it is
             TRUE ~ as.character(age)),
         sex = ifelse(sex == "All", "", sex),
         # totals should be blank, not e.g. 'all'
         `housing type` = ifelse(`housing type` == "all_households_000s", "", `housing type`),
         sex = ifelse(sex == "all", "", sex),
         # If value is NA give a reason for why it is blank (as below) or...
         `observation status` = ifelse(is.na(value), "Missing value", "Normal value")
         ) %>% 
  # you can also use pattern matching to change level names, e.g. removing the 
  # word 'type' fromthe housing types column
  mutate(`housing type` = stringr::str_replace(`housing type`,"type_|_types",  "")) %>% 
  # add columns that don't exist yet (e.g. for SDMX)
  # (you need backticks if the column name has spaces)
  mutate(units = "Number",
         `unit multiplier` = "Thousands") %>% 
  # ... or remove it using filter() as the commented line below
  # filter(!is.na(Value)) %>%
  # we changed everything to lowercase at the top of the script, 
  # so now we need to change them back to the correct case
  mutate(across(where(is.character), str_to_sentence)) %>% 
  # if you then have to change country as well:
  # mutate(Country = str_to_title(Country)) %>% 

  # order of disaggregations depend on order they appear, so sort these now
  # arrange will put them in alphanumeric order, so if you dont want these follow the age example here
  left_join(age_order, by = "age") %>% 
  arrange(year, age_order, sex) %>% 
  # Put columns in the order we want them.
  # this also gets rid of the column age_order which has served its purpose and is no longer needed
  select(year, `housing type`, age, sex, 
         `observation status`, `units`, `unit multiplier`,
         value)

# put the column names in sentence case
names(csv_formatted) <- str_to_sentence(names(csv_formatted))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))




