# author: Katie Gummer
# date: 15/08/2023

# Code to automate data update for indicator 9-c-1 (Proportion of population covered by a mobile network, by technology)

#### read in data ####

coverage_source_data <- get_type1_data(header_row, filename, tabname)

#### select the necessary columns ####
coverage_data <- coverage_source_data %>% 
  select("TimePeriod", "SeriesCode", "Value")

#### renaming column ####
coverage_data <- coverage_data %>%
  rename("Year" = "TimePeriod", 
         "Technology" = "SeriesCode")

#### correcting data ####
coverage_data$Technology[coverage_data$Technology == 'IT_MOB_2GNTWK'] <- '2G mobile network'

coverage_data$Technology[coverage_data$Technology == 'IT_MOB_3GNTWK'] <- '3G mobile network'

coverage_data$Technology[coverage_data$Technology == 'IT_MOB_4GNTWK'] <- '4G mobile network'



#### Format csv ####

csv_formatted <- coverage_data %>% 
  mutate("Units" = "Percentage (%)",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value")



csv_output <- csv_formatted %>%            
  select("Year", "Technology", "Observation status", "Unit multiplier", "Units", "Value")





