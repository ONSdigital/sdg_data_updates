# Michael Nairn update for indicator 3-9-2
# date 17/02/2023


# Population data, and England and Wales mortality data is from Nomis. 
  # They do not require a manual download as they have a stable weblink 

#,Scotland and Northern Ireland data have to be downlaoded from source as .csv files

  
#### download and read in data ####
england_wales_data <- read.csv(england_wales_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

scotland_data <- read.csv(england_wales_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

n_ireland_data <- read.csv(england_wales_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

population_data <- read.csv(population_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 
 


#### Clean the population data #### 

# Select and rename relevant columns
population_small <- population_data %>%
  select(DATE, GEOGRAPHY_NAME, GEOGRAPHY_TYPE,
                  SEX_NAME, OBS_VALUE, OBS_STATUS_NAME) %>% 
  rename(Year = DATE,
         Value = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME,
         Sex = SEX_NAME) %>% 
  mutate(`Cause of death` = "")



#### Clean the England and Wales data #### 

# Select and rename relevant columns
england_wales_small <- england_wales_data %>%
  select(DATE, CAUSE_OF_DEATH_NAME, GEOGRAPHY_NAME, GEOGRAPHY_TYPE,
         GENDER_NAME, OBS_VALUE, OBS_STATUS_NAME) %>% 
  rename(Year = DATE,
         `Cause of death` = CAUSE_OF_DEATH_NAME,
         Value = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME,
         Sex = GENDER_NAME)



#### Clean the Scotland data ####




#### Clean the Northern Ireland data ####




#### Combine the mortality data #### 




#### Clean the Mortality data ####




#### Group cause of death, where appropriate, according to UN metadata ####






# clean up the denominator data-------------------------------------------------

clean_population <- population_data %>% 
  # not all data will be relevant so filter it for what you need
  filter(MEASURES_NAME == "Value" & # don't need confidence intervals
           # the numerator data isn't disaggregated by sex or age, so only need the totals
           SEX_NAME == "Total" &
           AGE_NAME == "All ages") %>%  
  # country and region need to be in separate columns
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "Regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>% 
  rename(population = OBS_VALUE) %>% 
  # make date a string as the date column you later use to join the two 
  # dataframes is a character string
  mutate(DATE_CODE = as.character(DATE_CODE)) %>% 
  # make sure you have filtered for only things you need and that you have selected 
  # all the relevant columns. 
  select(DATE_CODE, 
         Country, Region, 
         population)

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

