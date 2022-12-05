# This file is called by compile_tables.R.
# It processes the data about number of deaths caused by natural disasters in England
# and Wales 2013-present along with the Age-Standardised mortality rate for those killed
# by natural disasters.


# Load in the datasets----

# Includes data for all causes of death (non-disaster related)
all_deaths <- read.csv(nomis_disaster_deaths_link) %>%
  mutate(across(where(is.factor), as.character)) %>%
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

all_mortality <- read.csv(nomis_mortality_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

# Define some functions----

get_GeoCode <- function(countryName){
  if(countryName=="England") {return("E92000001")}
  else if(countryName=="Wales") {return("W92000004")}
  else if(countryName=="") {return("K04000001")}
  else {return("")}
}


# Aggregate before cleaning----

all_disaster_deaths <- all_deaths %>% 
  filter(grepl("^[X][3][0-9]", CAUSE_OF_DEATH_NAME))

all_disaster_deaths_any_cause <- all_disaster_deaths %>% # Any disaster cause of death
   group_by(DATE, GEOGRAPHY_NAME, GENDER_NAME) %>% 
   summarise(OBS_VALUE = sum(OBS_VALUE)) %>% 
   mutate(CAUSE_OF_DEATH_NAME = "")

all_disaster_deaths_with_totals <- all_disaster_deaths %>% bind_rows(all_disaster_deaths_any_cause)


  

# Clean up

all_disaster_deaths_with_totals_cleaned <- all_disaster_deaths_with_totals %>%
  mutate(Series = "Number of deaths from exposure to forces of nature",
         Units = "Number",
         `Observation status` = all_deaths$OBS_STATUS_NAME %>% unique())
  


# Clean up all_mortality----

all_mortality_cleaned <- all_mortality %>% 
  filter(grepl("^[X][0-9][0-9]", CAUSE_OF_DEATH_NAME)) %>% 
  mutate(Series = "Age-standardised mortality rates per 100,000 population",
         Units = "Rate per 100,000 population",
         CAUSE_OF_DEATH_NAME = "")
  


recent_data <- all_disaster_deaths_with_totals_cleaned %>% bind_rows(all_mortality_cleaned)

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
  mutate(Sex = ifelse(Sex == "Total", "", Sex),
         Country = ifelse(Country == "England and wales", "", Country),
         GeoCode = lapply(Country, get_GeoCode) %>% as.character(),
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
         Value = as.numeric(Value)) #%>%
  # Sometimes Nomis will include an entry for a year but have NA for observed valued, like for 2021 currently, you may wish to exclude
          #filter(!is.na(Value))


  