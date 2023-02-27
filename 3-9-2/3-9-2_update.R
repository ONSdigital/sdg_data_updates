# Michael Nairn update for indicator 3-9-2
# date 17/02/2023


# Population data, and England and Wales mortality data is from Nomis. 
  # They do not require a manual download as they have a stable weblink 

#,Scotland and Northern Ireland data have to be downlaoded from source as .csv files

  
#### download and read in data ####
england_wales_data <- read.csv(england_wales_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

scotland_NI_data <- read.csv(scotland_NI_data) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

population_data <- read.csv(population_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 
 


#### Clean the population data #### 

# Select and rename relevant columns
population_small <- population_data %>%
  select(DATE, GEOGRAPHY_NAME, GEOGRAPHY_TYPE,
                  SEX_NAME, OBS_VALUE, OBS_STATUS_NAME) %>% 
  rename(Year = DATE,
         Value = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME,
         Sex = SEX_NAME)

# Add in country, region, and cause of death columns
population_clean <- population_small %>%
  mutate(`Cause of death` = "") %>%
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "Regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>%
  select(Year, `Cause of death`, Country, Region, Sex, `Observation status`, Value)

population_clean$Sex <- gsub("Total", "", population_clean$Sex)

#### Clean the England and Wales data #### 

# Select and rename relevant columns
england_wales_small <- england_wales_data %>%
  select(DATE, CAUSE_OF_DEATH_NAME, GEOGRAPHY_NAME, GEOGRAPHY_TYPE,
         GENDER_NAME, OBS_VALUE, OBS_STATUS_NAME) %>% 
  rename(Year = DATE,
         `Cause of death` = CAUSE_OF_DEATH_NAME,
         Value = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME,
         Sex = GENDER_NAME) %>% 
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "Regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>%
  select(Year, `Cause of death`, Country, Region, Sex, `Observation status`, Value)



#### Clean the Scotland and NI data ####
scotland_NI_small <- scotland_NI_data %>%
  mutate(Region = "") %>%
  rename(`Cause of death` = Cause.of.death,
         `Observation status` = Observation.status) %>%
  select(Year, `Cause of death`, Country, Region, Sex, `Observation status`, Value)



#### Combine the Mortality data #### 

mortality <- rbind(scotland_NI_small, england_wales_small)


#### Group cause of death, where appropriate, according to UN metadata ####

mortality_grouped <- mortality %>%
  mutate(`Cause of death` = recode(`Cause of death`, 
          "A00 cholera" = "Diarrhoea",
          "A01 typhoid and paratyphoid fevers" = "Diarrhoea",
          "A03 shigellosis" = "Diarrhoea",
          "A04 other bacterial intestinal infections" = "Diarrhoea",
          "A06 amoebiasis" = "Diarrhoea",
          "A07 other protozoal intestinal diseases" = "Diarrhoea",
          "A08 viral and other specified intestinal infections" = "Diarrhoea",
          "A09 other gastroenteritis and colitis of infectious and unspecified origin" = "Diarrhoea",
          "B76 hookworm diseases" = "Intestinal nematode infections",
          "B77 ascariasis" = "Intestinal nematode infections",
          "B79 trichuriasis" = "Intestinal nematode infections",
          "E40-e46 malnutrition" = "Protein-energy malnutrition",
          "H65 nonsuppurative otitis media" = "Acute respiratory infections",
          "H66 suppurative and unspecified otitis media" = "Acute respiratory infections",
          "J00-j06 acute upper respiratory infections" = "Acute respiratory infections",
          "J09-j18 influenza and pneumonia" = "Acute respiratory infections",
          "J20-j22 other acute lower respiratory infections" = "Acute respiratory infections",
          "P23 congenital pneumonia" = "Acute respiratory infections"))

mortality_grouped$Sex <- gsub("Total", "", mortality_grouped$Sex)


#### Calculate United Kingdom totals ####

# UK_added <- mortality_grouped %>%
  # mutate(Country = "United Kingdom")

# Add together when "Region" == "", and Year, Cause of death, Sex are all the same.
  # Name United Kingdom


#### Join mortality and population data #### 
proportion_data <- mortality_grouped %>% 
  left_join(population_clean, by = c("Year", "Country", "Sex", "Region"))


#### Calculate proportion per million population ####

proportion_data <- proportion_data %>%
  mutate(Value = 1000000*(Value.x/Value.y))


#### Format data for csv file ####
#






