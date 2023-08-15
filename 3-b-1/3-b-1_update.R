# Date: 15/08/2023
# Author: Michael Nairn

# 3-b-1 update script


#### Child vaccination ####

#### Read in and select country data ####
Age_1_data <- read_excel(filename_vaccines, tabname_country_age1, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 1st birthday (%)") %>%
  rename(Country = ...1,
         Value = `Percentage vaccinated`) %>%
  select(Country, Series, Value)


Age_2_data <- read_excel(filename_vaccines, tabname_country_age2, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 2nd birthday (%)") %>%
  rename(Country = ...1,
         Value = `Percentage vaccinated by their 2nd birthday`) %>%
  select(Country, Series, Value)

Age_5_data <- read_excel(filename_vaccines, tabname_country_age5, skip = 11)%>%
  mutate(Series = "Proportion of children vaccinated by 5th birthday (%)") %>%
  rename(Country = ...1,
         Value = `Percentage vaccinated by their 5th birthday`) %>%
  select(Country, Series, Value)


#### Bind datasets and remove NA rows ####
country_data <- rbind(Age_1_data, 
                      Age_2_data,
                      Age_5_data) %>%
  drop_na(Country | Value) %>%
  mutate(Region = "",
         `Local Authority` = "") %>%
  select(Series, Country, Region, `Local Authority`, Value)


#### Read in and select region data ####

Age_1_region_data <- read_excel(filename_vaccines, tabname_region_age1, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 1st birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(Region = ...1,
         Value = `Percentage vaccinated`) %>%
  select(Country, Region, Series, Value)

Age_2_region_data <- read_excel(filename_vaccines, tabname_region_age2, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 2nd birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(Region = ...1,
         Value = `Percentage vaccinated by their 2nd birthday`) %>%
  select(Country, Region, Series, Value)

Age_5_region_data <- read_excel(filename_vaccines, tabname_region_age5, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 5th birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(Region = ...1,
         Value = `Percentage vaccinated by their 5th birthday`) %>%
  select(Country, Region, Series, Value)


region_data <- rbind(Age_1_region_data, 
                 Age_2_region_data,
                 Age_5_region_data) %>%
  mutate(`Local Authority` = "") %>% 
  drop_na(Region | Value) %>%
  select(Series, Country, Region, `Local Authority`, Value)



#### Read in and select LA data ####

Age_1_LA_data <- read_excel(filename_vaccines, tabname_LA_age1, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 1st birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(`Local Authority` = ...2,
         Value = `Percentage vaccinated`) %>%
  select(Series, Country, `Local Authority`, Value)

Age_2_LA_data <- read_excel(filename_vaccines, tabname_LA_age2, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 2nd birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(`Local Authority` = ...2,
         Value = `Percentage vaccinated by their 2nd birthday`) %>%
  select(Series, Country, `Local Authority`, Value)

Age_5_LA_data <- read_excel(filename_vaccines, tabname_LA_age5, skip = 11) %>%
  mutate(Series = "Proportion of children vaccinated by 5th birthday (%)") %>%
  mutate(Country = "England") %>%
  rename(`Local Authority` = ...2,
         Value = `Percentage vaccinated by their 5th birthday`) %>%
  select(Series, Country, `Local Authority`, Value)



#### Bind datasets and remove NA rows ####
LA_data <- rbind(Age_1_LA_data, 
                      Age_2_LA_data,
                      Age_5_LA_data) %>%
  drop_na(`Local Authority` | Value) %>%
  mutate(Region = "") %>%
  select(Series, Country, Region, `Local Authority`, Value)


vaccination_data <- rbind(country_data,
                          region_data,
                          LA_data) %>%
  mutate(Year = data_year) %>%
  select(Year, Series, Country, Region, `Local Authority`, Value)



#### Adolescent HPV vaccnations ####

#### Read in and select data ####
HPV_LA_data <- read_excel(filename_HPV, tabname_HPV_LA, skip = 4)
HPV_region_data <- read_excel(filename_HPV, tabname_HPV_region, skip = 3)
HPV_country_data <- read_excel(filename_HPV, tabname_HPV_UK, skip = 7)






# tidy up the year and sex columns
region_data_clean$Year <- gsub("Rate per 100", "", region_data_clean$Year)
region_data_clean$Year  <- gsub("\\\r\n", "", region_data_clean$Year)
region_data_clean$Year  <- gsub("\\[|\\]|,", "", region_data_clean$Year)
region_data_clean$Year  <- gsub(" 000 note 4", "", region_data_clean$Year)


#### Bind all data together ####
clean_data <- rbind(country_data_clean, 
                    age_data_clean,
                    region_data_clean)

clean_data$Sex <- gsub("Persons", "", clean_data$Sex)
clean_data$Sex <- gsub("Males", "Male", clean_data$Sex)
clean_data$Sex <- gsub("Females", "Female", clean_data$Sex)


#### Add in extra columns - Units and Observation status ####
csv_formatted <- clean_data %>%
  mutate(Units = "Rate per 100,000 population") %>%
  mutate(`Observation status` = case_when(
    Value == "[x]" ~ "Missing value",
    TRUE ~ "Normal value")) %>% 
  select(Year, Country, Region, Sex, Age, Units, `Observation status`, Value)

#### Alphabetically order ####
csv_formatted <- csv_formatted[order(csv_formatted$Sex), ]


#### Final checks ####

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)

# If false you may need to remove duplicate rows. 
# if true, run anyway
csv_output <- unique(csv_formatted)