# Michael Nairn
# date: 24/03/2023
# indicator 3.9.3 automation


# download and read in data ----------------------------------------------------
# regions dataset is separate as filtered by a different age-range, but if now reporting blanks may not be needed
NOMIS_data <- read.csv(NOMIS_link_temp) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# ---------------------------clean up totals data-------------------------------
clean_data <- NOMIS_data %>% 
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
  mutate('Unintentional poisoning category' = recode(CAUSE_OF_DEATH_CODE,
                                    "X40" = "Accidental poisoning by and exposure to nonopioid analgesics, antipyretics and antirheumatics",
                                    "X43" = "Accidental poisoning by and exposure to other drugs acting on the autonomic nervous system",
                                    "X44" = "Accidental poisoning by and exposure to other and unspecified drugs, medicaments and biological substances",
                                    "X46" = "Accidental poisoning by and exposure to organic solvents and halogenated hydrocarbons and their vapours",
                                    "X47" = "Accidental poisoning by and exposure to other gases and vapours",
                                    "X48" = "Accidental poisoning by and exposure to pesticides",
                                    "X49" = "Accidental poisoning by and exposure to other and unspecified chemicals and noxious substances")) %>%
  

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
  mutate(Country = toTitleCase(Country)) %>%
  mutate(Region = toTitleCase(Region)) %>%
  rename( Year = DATE,
          Value = OBS_VALUE)  %>%
  
  select(c("Year", "Country", "Region", "Age", "Sex", "Unintentional poisoning category",
           "Unit measure", "Unit multiplier", "Observation status", "Value"))

csv_formatted$Region <- gsub("the Humber", "The Humber", csv_formatted$Region)


# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_formatted <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value)) 


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_formatted)

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_output)) == nrow(csv_output)


