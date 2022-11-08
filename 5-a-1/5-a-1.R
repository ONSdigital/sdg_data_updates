#### Michael Nairn automation code for SDG Indicator 5-a-1 ####

# 8th November 2022 

# Data from Nomis. It does not require a manual download as it 
# has a stable weblink (API is also available here but not used as weblink is 
# more straightforward)


# This indicator asks for Proportion of total agricultural population with
 # ownership or secure rights over agricultural land, by sex

# Therefore need three datasets: Male, Female, total population


# download and read in data ----------------------------------------------------
NOMIS_data <- read.csv(NOMIS_data) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Ensure annual (Jan-Dec) data, as opposed to quarters #### 

# get the months the years run from and to (to use in QA)- this can be removed
# if data are only published annually. It is included for data published more 
# frequently as a check that the right data have been pulled from nomis 
months <- as.character(unique(NOMIS_data$DATE_NAME))
months_no_years <- gsub('[[:digit:]]+', '', months)
unique_months <- unique(months_no_years)


# when running back series, we could download just the annual data so that we can download more years at once.
# However, for standard updates we should only need to download the last two years at the most.
# To ensure that we only use the Jan to Dec data (for example), we need to download all quarters.
# This is because the nomis download link is based on the number of quarters since the most recent data.
multiple_quarters <- ifelse(length(unique_months) > 1, TRUE, FALSE)

# if this is a standard update and annual data are available up to different quarters, 
# we need to filter for the data made up to (usually) the end of the calendar year.
# required_month is specified in the config file.
if(multiple_quarters == TRUE) {
  numerator_annual <- numerator_data %>% 
    mutate(keep_quarter = ifelse(substr(DATE_CODE, 6, 7) == required_month, TRUE, FALSE)) %>% 
    filter(keep_quarter == TRUE) %>% 
    select(-keep_quarter)
}



#### Clean up data ####

NOMIS_clean <- NOMIS_data %>% 
  # we don't need confidence intervals or rates - though this may change in future
  filter(MEASURES_NAME == "Value" & MEASURE_NAME == "Count") %>% 
  # split the geographies so country and region are in separate columns
  mutate(
    Country = case_when(
      GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
      GEOGRAPHY_TYPE == "Regions" ~ "England",
      TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>%
  # select relevant columns
  select(DATE_CODE,
             Country,
             Region,
             C_SEX_NAME,
             MEASURE_NAME,
             MEASURES_NAME,
             OBS_VALUE,
             OBS_STATUS_NAME) %>% 
      # rename columns for output
      rename(Sex = C_SEX_NAME,
             `Observation status` = OBS_STATUS_NAME)





# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
nrow(distinct(clean_population)) == nrow(clean_population)

# join numerator and denominator data frames and do calculations ---------------

proportion_data <- occupations_filled %>% 
  # In this example, we are using annual data only, but multiple end points are 
  # available in the download (e.g year ending December, year ending march etc).
  # Because all the date_codes have the same month we can remove this information
  # (this would be different if, for example the data were quarterly)
  mutate(Year = substr(DATE_CODE, 1, 4)) %>% 
  left_join(clean_population, by = c("Year" = "DATE_CODE", "Country", "Region")) %>% 
  mutate(Value = (numerator/population) * 10000)

  
# format data for csv file -----------------------------------------------------
csv_formatted <- proportion_data %>% 
  mutate(
    Country = case_when(
      Country == "United kingdom" ~ "", 
      Country == "Northern ireland" ~ "Northern Ireland",
      TRUE ~ as.character(Country)),
    # I have mapped the observation status for these data, however please
    # check that this is correct for your indicator as wording and options 
    # may be different in other data sets
    `Observation status` = case_when(
      `Observation status` == "Estimate and confidence interval not available since the group sample size is zero or disclosive (0-2)" ~ 
        "Missing value; suppressed",
      `Observation status` == "Estimate is less than 500" ~ 
        "Missing value; data exist but were not collected",
      TRUE ~ as.character(`Observation status`))
  ) %>% 
  arrange(Year, Country, Region, `Occupation unit group`, `Occupation minor group`) %>% 
  rename(GeoCode = GEOGRAPHY_CODE) %>% 
  select(Year, `Occupation minor group`, `Occupation unit group`,
         Country, Region, GeoCode, `Observation status`, Value) 

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

