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


?pivot_longer

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
  mutate(Sex = "") %>%
  mutate(Region = "")


# combine the age columns

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

head(age_data_clean)



#### Read in region data ####
region_data <- read_excel(filename, tabname_region, skip = 3)

colnames(region_data)

region_small <- region_data %>%
  rename(Region = `Area of usual residence \r\n[note 2]`) %>%
  mutate(Country = "England") %>%
  mutate(Age = "")

#region_data_clean <- region_data_small %>%
  pivot_longer(cols = c(`2021 \r\nRate per 100,000 \r\n[note 4]`,
                        `2020 \r\nRate per 100,000 \r\n[note 4]`,
                        `2019 \r\nRate per 100,000 \r\n[note 4]`,
                        `205 to 29 \r\nRate per 100,000 \r\n[note 4]`,
                        `30 to 34 \r\nRate per 100,000 \r\n[note 4]`,
                        `35 to 39 \r\nRate per 100,000 \r\n[note 4]`,
                        `40 to 44 \r\nRate per 100,000 \r\n[note 4]`,
                        `45 to 49 \r\nRate per 100,000 \r\n[note 4]`,
                        `50 to 54 \r\nRate per 100,000 \r\n[note 4]`,
                        `55 to 59 \r\nRate per 100,000 \r\n[note 4]`,
                        `60 to 64 \r\nRate per 100,000 \r\n[note 4]`,
                        `65 to 69 \r\nRate per 100,000 \r\n[note 4]`,
                        `70 to 74 \r\nRate per 100,000 \r\n[note 4]`,
                        `75 to 79 \r\nRate per 100,000 \r\n[note 4]`,
                        `80 to 84 \r\nRate per 100,000 \r\n[note 4]`,
                        `85 to 89 \r\nRate per 100,000 \r\n[note 4]`,
                        `90+ \r\nRate per 100,000 \r\n[note 5]`),
               names_to = "Year",
               values_to = "Value") %>%
  select(Year, Country, Region, Age, Sex, Value)
  
  
# tidy up the year column
region_data_clean$Year <- gsub("Rate per 100", "", age_data_clean$Age)
age_data_clean$Year  <- gsub("\\\r\n", "", age_data_clean$Age)
age_data_clean$Year  <- gsub("\\[|\\]|,", "", age_data_clean$Age)
age_data_clean$Year  <- gsub("note 4", "", age_data_clean$Age)
age_data_clean$Year  <- gsub(" 000 ", "", age_data_clean$Age)


region_data_clean$Sex <- gsub("Persons", "", region_data_clean$Sex)


#### Bind all data together
clean_data <- rbind(country_clean, 
                      age_clean,
                    region_clean) 



#### Remove NAs from the csv that will be saved in Outputs ####
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_formatted_nas <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value)) 


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted_nas)) == nrow(csv_formatted_nas)

csv_formatted_nas <- csv_formatted_nas %>% 
  mutate(`Observation status` = "Normal value") %>%
  select(Year, Series, `Drug group`, `Local authority`, 
         Sex, Age, Ethnicity, Units, `Observation status`, Value) %>%
  arrange(Year, Series, `Drug group`, `Local authority`,
          Sex, Age, Ethnicity) 


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_formatted_nas)





