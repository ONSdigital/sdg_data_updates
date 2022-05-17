# Michael Nairn automated update for Indicator 3-4-1
# date: 13/05/2022
# This is based off the type_4_update template script made by Emma Wood.

# Type 4 data is data from Nomis. It does not require a manual download as it 
# has a stable weblink (API is also available here but not used as weblink is 
# more straightforward)
  
# indicators often require population numbers as the denominator, so this 
# template is based on an indicator for which the numerator is some series from
# nomis divided by population (also from nomis).

# Most comments can (should) be deleted in your file, and data renamed as appropriate 

# download and read in data ----------------------------------------------------
numerator_data_total <- read.csv(numerator_link_total) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

numerator_data_male <- read.csv(numerator_link_male) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

numerator_data_female <- read.csv(numerator_link_female) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

# bind the three datasets together
numerator_data <- rbind(numerator_data_total, numerator_data_female, numerator_data_male)



# clean up the numerator data---------------------------------------------------
clean_numerator <- numerator_data %>% 
  # we don't need confidence intervals - though this may change in future
  filter(MEASURES_NAME == "Value") %>% 
  # split the geographies so country and region are in separate columns
  mutate(
    Country = case_when(
      GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
      GEOGRAPHY_TYPE == "Regions" ~ "England",
      TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) 


cause_subtype <- clean_numerator %>% 
  # split the causes of death so cancer, cardiovascular disease, diabetes, and chronic respiratory disease
    # are in one column, and subtypes of chronic respiratory disease are in another.
   mutate(
    `Cause of death` = case_when(
      CAUSE_OF_DEATH %in% c(9700, 560, 9) ~ CAUSE_OF_DEATH_NAME, 
      substr(as.character(CAUSE_OF_DEATH), 1, 2) == "11" ~ "Chronic respiratory disease",
      TRUE ~ as.character(CAUSE_OF_DEATH)),
    Chronic_respiratory_disease_subtype = ifelse(`Cause of death` == "Chronic respiratory disease", CAUSE_OF_DEATH_NAME, "")) 


required_columns <- cause_subtype %>% 
  rename(Value = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME,
         `Chronic respiratory disease subtype` = Chronic_respiratory_disease_subtype) %>% 
  select(all_of(c("DATE_CODE", "Cause of death",
                  "Chronic respiratory disease subtype", 
                  "AGE_NAME", "GENDER_NAME",
                  "Country", "Region",
                  "GEOGRAPHY_CODE", "Observation status",
                  "Value")))

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_numerator dataframe should be unique
# so this should be TRUE
nrow(distinct(required_columns)) == nrow(required_columns)



# format data for csv file -----------------------------------------------------
csv_formatted <- required_columns %>% 
  mutate(DATE_CODE = as.integer(DATE_CODE), 
         `Observation status` = case_when(
           `Observation status` == "These figures are missing." ~ 
             "Missing value",
           TRUE ~ as.character(`Observation status`)),
         Age = ifelse(grepl("otal", AGE_NAME), 
                      "",  
                      substr(AGE_NAME, 6, nchar(AGE_NAME))), # remove any variant of "total" from age column
         Age = gsub("\\-", " to ", Age), # change the "-" in age column to "to"
         Age = str_to_sentence(Age)) %>% # Put age column in sentence case
  rename(`Type of disease` = CAUSE_OF_DEATH_NAME, 
         GeoCode = GEOGRAPHY_CODE, 
         Sex = GENDER_NAME,
         Year = DATE_CODE) 

csv_formatted <- csv_formatted %>% 
  select(all_of(c("Year", "Type of disease", "Chronic respiratory disease subtype",
                  "Age", "Sex", "Country", "Region",
                  "Observation status", "Value")))
                  

# Sorry this part below is disgusting!!

csv_formatted[csv_formatted == "North east"] <- "North East"
csv_formatted[csv_formatted == "South east"] <- "South East"
csv_formatted[csv_formatted == "West midlands"] <- "West Midlands"
csv_formatted[csv_formatted == "North west"] <- "North West"
csv_formatted[csv_formatted == "South west"] <- "South West"
csv_formatted[csv_formatted == "East midlands"] <- "East Midlands"
csv_formatted[csv_formatted == "Yorkshire and the humber"] <- "Yorkshire and The Humber"
csv_formatted[csv_formatted == "England and wales"] <- "England and Wales"
csv_formatted[csv_formatted == "Total"] <- ""
csv_formatted[csv_formatted == "Total (all ages)"] <- ""
csv_formatted[csv_formatted == "C00-c97 malignant neoplasms"] <- "Cancer"
csv_formatted[csv_formatted == "E10-e14 diabetes mellitus"] <- "Diabetes"
csv_formatted[csv_formatted == "I00-i99 ix diseases of the circulatory system"] <- "Circulatory diseases"
csv_formatted[csv_formatted == "J30-j39 other diseases of upper respiratory tract"] <- "Other diseases of upper respiratory tract"
csv_formatted[csv_formatted == "J40-j47 chronic lower respiratory diseases"] <- "Chronic lower respiratory diseases"
csv_formatted[csv_formatted == "J60-j70 lung diseases due to external agents"] <- "Lung diseases due to external agents"
csv_formatted[csv_formatted == "J80-j84 other respiratory diseases principally affecting the interstitium"] <- "Other respiratory diseases principally affecting the interstitium"
csv_formatted[csv_formatted == "J85-j86 suppurative and necrotic conditions of lower respiratory tract"] <- "Suppurative and necrotic conditions of lower respiratory tract"
csv_formatted[csv_formatted == "J90-j94 other diseases of pleura"] <- "Other diseases of pleura"
csv_formatted[csv_formatted == "J95 postprocedural respiratory disorders, not elsewhere classified"] <- "Postprocedural respiratory disorders, not elsewhere classified"
csv_formatted[csv_formatted == "J96 respiratory failure, not elsewhere classified"] <- "Respiratory failure, not elsewhere classified"
csv_formatted[csv_formatted == "J98 other respiratory disorders"] <- "Other respiratory disorders"



# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

