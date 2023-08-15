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







# tidy up the age column
age_data_clean$Age <- gsub("Rate per 100", "", age_data_clean$Age)
age_data_clean$Age  <- gsub("\\\r\n", "", age_data_clean$Age)
age_data_clean$Age  <- gsub("\\[|\\]|,", "", age_data_clean$Age)
age_data_clean$Age  <- gsub("note 5", "", age_data_clean$Age)
age_data_clean$Age  <- gsub(" 000 ", "", age_data_clean$Age)

age_data_clean$Age  <- gsub("\\+", " and over", age_data_clean$Age)

head(age_data_clean)


#### Read in region data ####
region_data <- read_excel(filename, tabname_region, skip = 3)

colnames(region_data)

region_data_small <- region_data %>%
  rename(Region = `Area of usual residence \r\n[note 2]`) %>%
  mutate(Country = "England") %>%
  mutate(Age = "")

colnames(region_data_small)


#### Combine the Year columns ####

# note for reviewer - probably an elegant way to do this using REGEX
region_data_clean <- region_data_small %>%
  pivot_longer(cols = c(`2021 \r\nRate per 100,000 \r\n[note 4]`,
                        `2020 \r\nRate per 100,000 \r\n[note 4]`,
                        `2019 \r\nRate per 100,000 \r\n[note 4]`,
                        `2018 \r\nRate per 100,000 \r\n[note 4]`,
                        `2017 \r\nRate per 100,000 \r\n[note 4]`,
                        `2016 \r\nRate per 100,000 \r\n[note 4]`,
                        `2015 \r\nRate per 100,000 \r\n[note 4]`,
                        `2014 \r\nRate per 100,000 \r\n[note 4]`,
                        `2013 \r\nRate per 100,000 \r\n[note 4]`,
                        `2012 \r\nRate per 100,000 \r\n[note 4]`,
                        `2011 \r\nRate per 100,000 \r\n[note 4]`,
                        `2010 \r\nRate per 100,000 \r\n[note 4]`,
                        `2009 \r\nRate per 100,000 \r\n[note 4]`,
                        `2008 \r\nRate per 100,000 \r\n[note 4]`,
                        `2007 \r\nRate per 100,000 \r\n[note 4]`,
                        `2006 \r\nRate per 100,000 \r\n[note 4]`,
                        `2005 \r\nRate per 100,000 \r\n[note 4]`,
                        `2004 \r\nRate per 100,000 \r\n[note 4]`,
                        `2003 \r\nRate per 100,000 \r\n[note 4]`,
                        `2002 \r\nRate per 100,000 \r\n[note 4]`,
                        `2001 \r\nRate per 100,000 \r\n[note 4]`,
                        `2000 \r\nRate per 100,000 \r\n[note 4]`,
                        `1999 \r\nRate per 100,000 \r\n[note 4]`,
                        `1998 \r\nRate per 100,000 \r\n[note 4]`,
                        `1997 \r\nRate per 100,000 \r\n[note 4]`,
                        `1996 \r\nRate per 100,000 \r\n[note 4]`,
                        `1995 \r\nRate per 100,000 \r\n[note 4]`,
                        `1994 \r\nRate per 100,000 \r\n[note 4]`,
                        `1993 \r\nRate per 100,000 \r\n[note 4]`,
                        `1992 \r\nRate per 100,000 \r\n[note 4]`,
                        `1991 \r\nRate per 100,000 \r\n[note 4]`,
                        `1990 \r\nRate per 100,000 \r\n[note 4]`,
                        `1989 \r\nRate per 100,000 \r\n[note 4]`,
                        `1988 \r\nRate per 100,000 \r\n[note 4]`,
                        `1987 \r\nRate per 100,000 \r\n[note 4]`,
                        `1986 \r\nRate per 100,000 \r\n[note 4]`,
                        `1985 \r\nRate per 100,000 \r\n[note 4]`,
                        `1984 \r\nRate per 100,000 \r\n[note 4]`,
                        `1983 \r\nRate per 100,000 \r\n[note 4]`,
                        `1982 \r\nRate per 100,000 \r\n[note 4]`,
                        `1981 \r\nRate per 100,000 \r\n[note 4]`),
               names_to = "Year",
               values_to = "Value") %>%
  select(Year, Country, Region, Age, Sex, Value)


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