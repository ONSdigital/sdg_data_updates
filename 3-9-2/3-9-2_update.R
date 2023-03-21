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
 


#### Clean the population data for denominator #### 

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


#### Group cause of death, where appropriate, according to UN metadata ####

mortality_grouped <- england_wales_small %>%
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


#### Sum each cause of death from sub-causes ####
mortality_summed <- mortality_grouped %>% 
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))
#this has worked



#### Calculate English regions, England, Wales and UK totals ####

mortality_summed_wales <- mortality_summed %>% 
  filter(Country == "Wales") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))

mortality_summed_england <- mortality_summed %>% 
  filter(Country == "England" & Region == "") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))

mortality_summed_regions <- mortality_summed %>% 
  filter(Region != "") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))

mortality_summed_uk <- mortality_summed %>% 
  filter(Region == "") %>%
  group_by(Year, `Cause of death`, Sex) %>% 
  summarize(Value = sum(Value)) %>%
  mutate(Country = "United Kingdom") %>% 
  mutate(Region = "") %>%
  select(Year, `Cause of death`, Country, Region, Sex, Value)


####  Calculate sex totals ####
mortality_summed_male <- mortality_summed %>% 
  filter(Sex == "Male") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))

mortality_summed_female <- mortality_summed %>% 
  filter(Sex == "Female") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))

mortality_summed_bothsex <- mortality_summed %>% 
  filter(Sex == "") %>%
  group_by(Year, `Cause of death`, Country, Region, Sex) %>% 
  summarize(Value = sum(Value))


#### Clean the Scotland and NI data ####
scotland_NI_small <- scotland_NI_data %>%
  mutate(Region = "") %>%
  rename(`Cause of death` = Cause.of.death,
         `Observation status` = Observation.status) %>%
  select(Year, `Cause of death`, Country, Region, Sex, Value)



#### Combine the Mortality data #### 

mortality <- rbind(mortality_summed_wales,
                   mortality_summed_england,
                   mortality_summed_regions,
                   mortality_summed_uk,
                   mortality_summed_male,
                   mortality_summed_female,
                   mortality_summed_bothsex)

# still need totals and then combine with scotland and NI




#### Join mortality and population data #### 
proportion_data <- mortality %>% 
  left_join(population_clean, by = c("Year", "Country", "Sex", "Region"))


#### Calculate proportion per million population ####

proportion_data <- proportion_data %>%
  mutate(Value = 1000000*(Value.x/Value.y)) %>%
  rename(`Cause of death` = `Cause of death.x`) %>%
  select(Year, `Cause of death`, Country, Region, Sex, Value)


#### Format data for csv file ####

csv_formatted <- proportion_data %>% 
  # Format countries and regions to title case
  mutate(Country = toTitleCase(Country),
         Region = toTitleCase(Region)) %>% 
  mutate(`Observation status` = "Undefined") %>%
  mutate('Unit measure' = "Rate per 1,000,000 population") %>%
  # Put columns in order required for csv file.
  select(Year, `Cause of death`, Country, Region, Sex, `Observation status`, Value) %>% 
  # Arrange data by Year, Country, region, Sex 
  arrange(Year, `Cause of death`, Country, Region, Sex)

# Correct spelling of Yorkshire and The Humber
csv_formatted$Region[csv_formatted$Region == "Yorkshire and the Humber"] <- "Yorkshire and The Humber"


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)


#### Remove NAs from the csv that will be saved in Outputs ####

# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted




