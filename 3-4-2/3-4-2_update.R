# Date: 28/07/2023
# Author: Michael Nairn


#### Read in country data ####
England_and_Wales_data <- read_excel(filename, tabname_EandW, skip = 3)
England_data <- read_excel(filename, tabname_England, skip = 3)
Wales_data <- read_excel(filename, tabname_Wales, skip = 3)

country_data <- rbind(England_and_Wales_data, 
                      England_data,
                      Wales_data) 


#### Select and rename relevant columns in country data ####

colnames(country_data)

country_data_small <- country_data %>% 
  rename(Country = `Area of usual residence \r\n[note 2]`,
         Year = `Year of death registration \r\n[note 3]`,
         Persons = `Persons \r\nRate per 100,000 \r\n[note 4]`,
         Male = `Males \r\nRate per 100,000 \r\n[note 4]`,
         Female = `Females \r\nRate per 100,000 \r\n[note 4]`) %>%
  mutate(Region = "") %>%
  mutate(Age = "")



# combine the three the sex columns

country_data_clean <- country_data_small %>%
  pivot_longer(cols = c(Persons, Male, Female),
               names_to = "Sex",
               values_to = "Value") %>%
  select(Year, Country, Region, Age, Sex, Value)
  

country_data_clean$Sex <- gsub("Persons", "", country_data_clean$Sex)

# ?pivot_longer

#### Read in Age data ####
England_and_Wales_age_data <- read_excel(filename, tabname_age_EandW, skip = 3)
England_age_data <- read_excel(filename, tabname_age_England, skip = 3)
Wales_age_data <- read_excel(filename, tabname_age_Wales, skip = 3)

age_data <- rbind(England_and_Wales_age_data, 
                      England_age_data,
                      Wales_age_data) 


#### Select and rename relevant columns in age data ####

colnames(age_data)

age_data_small <- age_data %>% 
  rename(Country = `Area of usual residence \r\n[note 2]`,
         Year = `Year of death registration \r\n[note 3]`) %>%
  mutate(Region = "")


#### Combine the age columns ####

# note for reviewer - probably an elegant way to do this using REGEX
age_data_clean <- age_data_small %>%
  pivot_longer(cols = c(`10 to 14 \r\nRate per 100,000 \r\n[note 5]`,
                        `15 to 19 \r\nRate per 100,000 \r\n[note 5]`,
                        `20 to 24 \r\nRate per 100,000 \r\n[note 5]`,
                        `25 to 29 \r\nRate per 100,000 \r\n[note 5]`,
                        `30 to 34 \r\nRate per 100,000 \r\n[note 5]`,
                        `35 to 39 \r\nRate per 100,000 \r\n[note 5]`,
                        `40 to 44 \r\nRate per 100,000 \r\n[note 5]`,
                        `45 to 49 \r\nRate per 100,000 \r\n[note 5]`,
                        `50 to 54 \r\nRate per 100,000 \r\n[note 5]`,
                        `55 to 59 \r\nRate per 100,000 \r\n[note 5]`,
                        `60 to 64 \r\nRate per 100,000 \r\n[note 5]`,
                        `65 to 69 \r\nRate per 100,000 \r\n[note 5]`,
                        `70 to 74 \r\nRate per 100,000 \r\n[note 5]`,
                        `75 to 79 \r\nRate per 100,000 \r\n[note 5]`,
                        `80 to 84 \r\nRate per 100,000 \r\n[note 5]`,
                        `85 to 89 \r\nRate per 100,000 \r\n[note 5]`,
                        `90+ \r\nRate per 100,000 \r\n[note 5]`),
               names_to = "Age",
               values_to = "Value") %>%
  select(Year, Country, Region, Age, Sex, Value)

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
  select(Year, Country, Region, Age, Sex, Units, `Observation status`, Value)

#### Alphabetically order ####
csv_formatted[with(csv_formatted, order(, Sex)), ]


#### Final checks ####

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)

# If false you may need to remove duplicate rows. 
  # if true, run anyway
csv_output <- unique(csv_formatted)


