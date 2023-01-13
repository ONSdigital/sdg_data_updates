# This file is called by compile_tables.R.
# It processes the data about number of deaths caused by natural disasters in England
# and Wales 2013-present along with the Age-Standardised mortality rate for those killed
# by natural disasters.


# Load in the datasets----

# Includes data for all causes of death (non-disaster related)
recent_deaths <- read.csv(nomis_disaster_deaths_link) %>%
  mutate(across(where(is.factor), as.character)) %>%
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  # Drop any rows if OBS_VALUE is missing
  filter(!is.na(OBS_VALUE))

recent_mortality <- read.csv(nomis_mortality_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>% 
  # Remove any rows if OBS_VALUE is missing
  filter(!is.na(OBS_VALUE))

# Define some functions----

get_GeoCode <- function(countryName){
  if(countryName=="England") {return("E92000001")}
  else if(countryName=="Wales") {return("W92000004")}
  else if(countryName=="") {return("K04000001")}
  else {return("")}
}

# Drop any rows if OBS_VALUE is missing----




# Aggregate before cleaning----

recent_disaster_deaths <- recent_deaths %>% 
  filter(grepl("^[X][3][0-9]", CAUSE_OF_DEATH_NAME))

recent_disaster_deaths_any_cause <- recent_disaster_deaths %>%
  # Group by DATE, GEOGRAPHY_NAME and GENDER_NAME then sum 
  # in order to aggregate by CAUSE_OF_DEATH_NAME
   group_by(DATE, GEOGRAPHY_NAME, GENDER_NAME) %>% 
   summarise(OBS_VALUE = sum(OBS_VALUE)) %>% 
   mutate(CAUSE_OF_DEATH_NAME = "",
          OBS_STATUS_NAME = recent_disaster_deaths$OBS_STATUS_NAME %>% unique())

recent_disaster_deaths_with_totals <- recent_disaster_deaths %>% bind_rows(recent_disaster_deaths_any_cause)


  

# Clean up

recent_disaster_deaths_with_totals_cleaned <- recent_disaster_deaths_with_totals %>%
  mutate(Series = "Number of deaths from exposure to forces of nature",
         Units = "Number",
         `Observation status` = recent_deaths$OBS_STATUS_NAME %>% unique())
  


# Clean up all_mortality----

recent_mortality_cleaned <- recent_mortality %>% 
  filter(grepl("^[X][3][0-9]", CAUSE_OF_DEATH_NAME)) %>% 
  mutate(Series = "Age-standardised mortality rates per 100,000 population",
         Units = "Rate per 100,000 population",
         CAUSE_OF_DEATH_NAME = "")
  

# Combine the data on number of people killed by disasters with the disaster mortality rates
recent_data <- recent_disaster_deaths_with_totals_cleaned %>% bind_rows(recent_mortality_cleaned)

recent_data_cleaned <- recent_data %>% 
  rename(Sex = GENDER_NAME, 
         `Cause of death` = CAUSE_OF_DEATH_NAME, 
         Value = OBS_VALUE, 
         Country = GEOGRAPHY_NAME, 
         Year = DATE) %>% 
  mutate(`Unit multiplier` = "",
         `Observation status` = OBS_STATUS_NAME) %>% 
  # Exclude any rows corresponding to data about non EW residents
  filter(Country %in% c("England", "Wales", "England and wales")) %>% 
  mutate(Sex = ifelse(Sex == "Total", "", Sex), # For every variable the aggregated value is called ""
         Country = ifelse(Country == "England and wales", "", Country),
         GeoCode = lapply(Country, get_GeoCode) %>% as.character(),
         # Get rid of the cause of death code, e.g. X32, from the beginning of `Cause of death`
         `Cause of death` = substring(`Cause of death`, 5, nchar(`Cause of death`)) %>% str_to_sentence()) %>% 
  select(Year, 
         Series, 
         Country, 
         Sex, 
         `Cause of death`, 
         `Observation status`, 
         `Unit multiplier`, 
         `Units`, 
         GeoCode, 
         Value)

recent_data_cleaned <- recent_data_cleaned %>% 
  mutate(Year = as.numeric(Year),
         Value = as.numeric(Value))


  