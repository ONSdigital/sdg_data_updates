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
  NOMIS_annual <- NOMIS_data %>% 
    mutate(keep_quarter = ifelse(substr(DATE_CODE, 6, 7) == required_month, TRUE, FALSE)) %>% 
    filter(keep_quarter == TRUE) %>% 
    select(-keep_quarter)
}



#### Clean up data ####

NOMIS_clean <- NOMIS_data %>% 
  # we don't need confidence intervals or rates - though this may change in future
  filter(MEASURES_NAME == "Value" & MEASURE_NAME == "Count" & C_OCCPUK11H_0_NAME != "Total") %>% 
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
         C_OCCPUK11H_0_NAME,
             MEASURE_NAME,
             MEASURES_NAME,
             OBS_VALUE,
             OBS_STATUS_NAME) %>% 
      # rename columns for output
      rename(Sex = C_SEX_NAME,
             `Occupation unit group` = C_OCCPUK11H_0_NAME,
             `Observation status` = OBS_STATUS_NAME)


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the NOMIS_clean dataframe should be unique
# so this should be TRUE
nrow(distinct(NOMIS_clean)) == nrow(NOMIS_clean)



#### Need to split out male, female, and population data ####

# This will allow us to calculate percentages.

NOMIS_female <- filter(NOMIS_clean, Sex == "Females")

NOMIS_male <- filter(NOMIS_clean, Sex == "Males")

NOMIS_population <- filter(NOMIS_clean, Sex == "All persons")



#### Join female or male and population data frames and do calculations ####

female_proportion_data <- NOMIS_female %>% 
  # join total population to female dataframe
  left_join(NOMIS_population, by = c("DATE_CODE", "Occupation unit group", "Country", "Region")) %>%
  # do calculation of percentage female of total 
  mutate(Value = 100*(OBS_VALUE.x/OBS_VALUE.y)) %>% 
  # Extract the year, without month, from DATE_CODE
  mutate(Year = substr(DATE_CODE, 1, 4)) %>%
  mutate(`Unit measure` = "Percentage (%)") %>%
  # select relevant columns, 
    # no need for total population information, post calculation.
  select(Year,
         `Occupation unit group`,
         Country,
         Region,
         Sex.x,
         Value,
         `Unit measure`,
         `Observation status.x`) %>%
  # rename observation status and sex
  rename(`Observation status` = `Observation status.x`,
         Sex = Sex.x)



male_proportion_data <- NOMIS_male %>% 
  # join total population to male dataframe
  left_join(NOMIS_population, by = c("DATE_CODE", "Occupation unit group", "Country", "Region")) %>%
  # do calculation of percentage male of total 
  mutate(Value = 100*(OBS_VALUE.x/OBS_VALUE.y)) %>% 
  # Extract the year, without month, from DATE_CODE
  mutate(Year = substr(DATE_CODE, 1, 4)) %>%
  mutate(`Unit measure` = "Percentage (%)") %>%
  # select relevant columns, 
  # no need for total population information, post calculation.
  select(Year,
         `Occupation unit group`,
         Country,
         Region,
         Sex.x,
         Value,
         `Unit measure`,
         `Observation status.x`) %>%
  # rename observation status and sex
  rename(`Observation status` = `Observation status.x`,
         Sex = Sex.x)



#### Bind female and male proportion dataframes together ####

proportion_data <- rbind(female_proportion_data, male_proportion_data) 


#### Format data for csv output file ####

csv_formatted <- proportion_data %>% 
  # Format countries and regions to title case
  mutate(Country = toTitleCase(Country),
         Region = toTitleCase(Region)) %>% 
  # Include correct wording in observation status for when data is not collected
  mutate(`Observation status` = case_when(
    `Observation status` == "Estimate is less than 500" ~ 
      "Missing value; suppressed",
    TRUE ~ as.character(`Observation status`))) %>% 
  mutate(`Observation status` = case_when(
    `Observation status` == "Estimate and confidence interval not available since the group sample size is zero or disclosive (0-2)" ~ 
      "Missing value; suppressed",
    TRUE ~ as.character(`Observation status`))) %>% 
  # Put columns in order required for csv file.
  select(Year, `Occupation unit group`,  Country, Region, Sex, `Observation status`, `Unit measure`, Value) %>%
  # Arrange data by Year, Country, region, Sex 
  arrange(Year, `Occupation unit group`, Country, Region, Sex)


# Remove countries from region column
  # Wales, Northern Ireland, and Scotland are listed as regions of England as well 
  # as countries

csv_formatted<-csv_formatted[!(csv_formatted$Region == "Wales" | 
                                 csv_formatted$Region == "Northern Ireland" |
                                 csv_formatted$Region == "Scotland"),]  

# Correct Occupational unit group to remove codes
csv_formatted$`Occupation unit group` <- gsub("1211 m", "M", csv_formatted$`Occupation unit group`)
csv_formatted$`Occupation unit group` <- gsub("1213 m", "M", csv_formatted$`Occupation unit group`)
csv_formatted$`Occupation unit group` <- gsub("121 m", "M", csv_formatted$`Occupation unit group`)


# Correct males to male and females to female
csv_formatted$Sex <- gsub("Females", "Female", csv_formatted$Sex)
csv_formatted$Sex <- gsub("Males", "Male", csv_formatted$Sex)

# Correct spelling of Yorkshire and The Humber
csv_formatted$Region[csv_formatted$Region == "Yorkshire and the Humber"] <- "Yorkshire and The Humber"
csv_formatted$Country[csv_formatted$Country == "United Kingdom"] <- ""


#### Remove NAs from the csv that will be saved in Outputs ####

# this changes Value to a character so will still use csv_formatted in the 
  # R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

