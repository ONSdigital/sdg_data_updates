# date: 12/04/2022

#load packages
library(tidyr)
library(dplyr)
library(stringr)
library(tibble)
library(stringr)
library(dplyr)


# download and read in data ----------------------------------------------------
# regions dataset is separate as filtered by a different age-range, but if now reporting blanks may not be needed
total_data <- read.csv(total_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

male_data <- read.csv(male_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

female_data <- read.csv(female_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

regions_data <- read.csv(regions_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

all_data <- bind_rows(total_data, regions_data, female_data, male_data)

# ---------------------------clean up totals data-------------------------------
clean_data <- all_data %>% 
  # CSV creates a lot of columns we don't need so selecting relevant columns
  select(DATE,
         GEOGRAPHY_NAME,
         GEOGRAPHY_TYPE,
         CAUSE_OF_DEATH_CODE,
         GENDER_NAME,
         AGE_NAME,
         MEASURE_NAME,
         OBS_STATUS_NAME,
         OBS_VALUE)  %>%
  
  #Underlying causes data comes in ICD-10 classification codes, renaming into plain English
  mutate('Type of disease' = recode(CAUSE_OF_DEATH_CODE,
                                    "C00-c97" = "Cancer",
                                    "E10-e14" = "Diabetes",
                                    "I00-i99" = "Cardiovascular disease",
                                    "J30-j39" = "Chronic repiratory disease",
                                    "J40-j47" = "Chronic repiratory disease",
                                    "J60-j70" = "Chronic repiratory disease",
                                    "J80-j84" = "Chronic repiratory disease",
                                    "J85-j86" = "Chronic repiratory disease",
                                    "J90-j94" = "Chronic repiratory disease",
                                    "J95" = "Chronic respiratory disease",
                                    "J96" = "Chronic respiratory disease",
                                    "J98" = "Chronic respiratory disease")) %>%
  
  
  #creating chronic respiratory (J30-98) sub-category 
  mutate ('Chronic respiratory disease subtype' = recode(CAUSE_OF_DEATH_CODE,
                                                         "C00-c97" = "",
                                                         "E10-e14" = "",
                                                         "I00-i99" = "",
                                                         "J30-j39" = "Other diseases of upper respiratory tract",
                                                         "J40-j47" = "Chronic lower respiratory diseases",
                                                         "J60-j70" = "Lung diseases due to external agents",
                                                         "J80-j84" = "Other respiratory diseases principally affecting the interstitium",
                                                         "J85-j86" = "Suppurative and necrotic conditions of lower respiratory tract",
                                                         "J90-j94" = "Other diseases of pleura",
                                                         "J95" = "Postprocedural respiratory disorders, not elsewhere classified",
                                                         "J96" = "Respiratory failure, not elsewhere classified",
                                                         "J98" = "Other respiratory disorders")) %>%
  mutate ('Chronic respiratory disease subtype' = recode(CAUSE_OF_DEATH_CODE,
                                                         "C00-c97" = "",
                                                         "E10-e14" = "",
                                                         "I00-i99" = "",
                                                         "J30-j39" = "Other diseases of upper respiratory tract",
                                                         "J40-j47" = "Chronic lower respiratory diseases",
                                                         "J60-j70" = "Lung diseases due to external agents",
                                                         "J80-j84" = "Other respiratory diseases principally affecting the interstitium",
                                                         "J85-j86" = "Suppurative and necrotic conditions of lower respiratory tract",
                                                         "J90-j94" = "Other diseases of pleura",
                                                         "J95" = "Postprocedural respiratory disorders, not elsewhere classified",
                                                         "J96" = "Respiratory failure, not elsewhere classified",
                                                         "J98" = "Other respiratory disorders")) %>%
  select(-CAUSE_OF_DEATH_CODE) 


#------------------CSV formatted---------------------------------------------------------
#formatting names/columns so platform appropriate
csv_formatted <- clean_data %>%
  mutate("Unit measure" = "Age-standardised mortality rate per 100,000 population",
         "Unit multiplier" = "Units") %>%
  
  #regions need associated country name 
  # split the geographies so country and region are in separate columns
  mutate(
    Country = case_when(
      GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
      GEOGRAPHY_TYPE == "Regions" ~ "England",
      TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>%
  
  
  mutate(Age = ifelse(grepl("otal", AGE_NAME), 
                      "",  
                      substr(AGE_NAME, 6, nchar(AGE_NAME))), #getting rid of Aged at start of each column
         Age = gsub("\\-", " to ", Age), 
         Age = str_to_sentence(Age)) %>%
  
  mutate("Sex" = ifelse(GENDER_NAME == "Total", "", GENDER_NAME))  %>%
  mutate("Observation status" = ifelse(OBS_STATUS_NAME == "These figures are missing.", "Missing value", OBS_STATUS_NAME)) %>%
  
  rename( Year = DATE,
          Value = OBS_VALUE)  %>%
  
  select(c("Year", "Country", "Region", "Age", "Sex", "Type of disease", "Chronic respiratory disease subtype",
           "Unit measure", "Unit multiplier", "Observation status", "Value"))

csv_formatted$Country <- gsub("Total mortality", "", csv_formatted$Country)


# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)
