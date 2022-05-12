# Michael Nairn automated update for Indicator 3-9-3
# date: 11/05/2022
# This is based off the type_4_update template script made by Emma Wood.

# Type 4 data is data from Nomis. It does not require a manual download as it 
# has a stable weblink (API is also available here but not used as weblink is 
# more straightforward)
  
# indicators often require population numbers as the denominator, so this 
# template is based on an indicator for which the numerator is some series from
# nomis divided by population (also from nomis).

# Most comments can (should) be deleted in your file, and data renamed as approriate 

# download and read in data ----------------------------------------------------
numerator_data_total <- read.csv(numerator_link_total) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

numerator_data_male <- read.csv(numerator_link_male) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

numerator_data_female <- read.csv(numerator_link_female) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

# bind the three datasets together
numerator_data <- rbind(numerator_data_total, numerator_data_female, numerator_data_male)


population_data <- read.csv(population_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 
  

# clean up the numerator data---------------------------------------------------
clean_numerator <- numerator_data %>% 
  # we don't need confidence intervals - though this may change in future
  filter(MEASURES_NAME == "Value") %>% 
  # split the geographies so country and region are in separate columns
  # and (for this example, we also split the occupation codes into minor group and unit group 
  mutate(
    Country = case_when(
      GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
      GEOGRAPHY_TYPE == "Regions" ~ "England",
      TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, ""))


clean_numerator <- rename(clean_numerator, Value = OBS_VALUE,
                          `Observation status` = OBS_STATUS_NAME)


clean_numerator <- select(clean_numerator, all_of(c("DATE_CODE", "CAUSE_OF_DEATH_NAME",
                              "AGE_NAME", "GENDER_NAME",
                              "Country", "Region",
                              "GEOGRAPHY_CODE", "Observation status",
                              "Value")))

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_numerator dataframe should be unique
# so this should be TRUE
nrow(distinct(clean_numerator)) == nrow(clean_numerator)


# clean up the denominator data-------------------------------------------------

clean_population <- population_data %>% 
  # not all data will be relevant so filter it for what you need
  filter(MEASURES_NAME == "Value") %>%  
  # country and region need to be in separate columns
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "Regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>% 
  rename(Population = OBS_VALUE) %>% 
  # make sure you have filtered for only things you need and that you have selected 
  # all the relevant columns. 
  select(DATE_CODE, 
         Country, Region, 
         Population)

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
nrow(distinct(clean_population)) == nrow(clean_population)

# join numerator and denominator data frames and do calculations ---------------

proportion_data <- clean_numerator %>% 
  # In this example, we are using annual data only, but multiple end points are 
  # available in the download (e.g year ending December, year ending march etc).
  # Because all the date_codes have the same month we can remove this information
  # (this would be different if, for example the data were quarterly)
  left_join(clean_population, by = c("DATE_CODE", "Country", "Region")) %>% 
  mutate(Value = (Value/Population) * 10000)


  
# format data for csv file -----------------------------------------------------
csv_formatted <- proportion_data %>% 
  mutate(DATE_CODE = as.integer(DATE_CODE), `Observation status` = case_when(
      `Observation status` == "These figures are missing." ~ 
        "Missing value",
          TRUE ~ as.character(`Observation status`))) 


csv_formatted <- rename(csv_formatted, `Unintentional poisoning category` = CAUSE_OF_DEATH_NAME, 
         GeoCode = GEOGRAPHY_CODE, Sex = GENDER_NAME, Age = AGE_NAME, Year = DATE_CODE) 

csv_formatted[csv_formatted == "North east"] <- "North East"
csv_formatted[csv_formatted == "South east"] <- "South East"
csv_formatted[csv_formatted == "West midlands"] <- "West Midlands"
csv_formatted[csv_formatted == "North west"] <- "North West"
csv_formatted[csv_formatted == "South west"] <- "South West"
csv_formatted[csv_formatted == "East midlands"] <- "East Midlands"
csv_formatted[csv_formatted == "Yorkshire and the humber"] <- "Yorkshire and The Humber"

csv_formatted <- select(csv_formatted, -Population)
  
# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

