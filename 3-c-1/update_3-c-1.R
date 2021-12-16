population_data <- read.csv(nomis_population_link) %>% 
  mutate(across(where(is.factor), as.character)) 
employment_data <- read.csv(nomis_employment_link) %>% 
  mutate(across(where(is.factor), as.character)) 

# get the months the years run from and to (to use in QA)
months <- as.character(unique(employment_data$DATE_NAME))
months_no_years <- gsub('[[:digit:]]+', '', months)
unique_months <- unique(months_no_years)

# when running back series, we only download annual data so that we can download more years at once.
# However, for standard updates we only need to download the last two years at the most.
# To ensure that we only use the Jan to Dec data, we need to download all quarters.
# This is because the nomis download link is based on the number of quarters since the most recent data.
multiple_quarters <- ifelse(length(unique_months) > 1, TRUE, FALSE)

# if this is a standard update (i.e. quarterly data), need to filter for the right months
if(multiple_quarters == TRUE) {
  employment_data <- employment_data %>% 
    mutate(keep_quarter = ifelse(substr(DATE_CODE, 6, 7) == "12", TRUE, FALSE)) %>% 
    filter(keep_quarter == TRUE)
}

minor_occupations <- unique(employment_data$C_OCCPUK11H_0_NAME[employment_data$C_OCCPUK11H_0_TYPE == "3-digit occupation"])
occupation_lookup <- data.frame(minor = minor_occupations,
                                code = substring(minor_occupations, 1, 3)) %>% 
  mutate(across(where(is.factor), as.character))

employment_data_clean <- employment_data %>% 
  filter(MEASURES_NAME == "Value",  # don't need confidence intervals
         C_SEX == 0) %>% 
  # split the geographies so country and region are in separate columns
  # and the occupation codes into minor group and unit group 
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "regions" ~ "England",
    TRUE ~ ""),
    
    Region = ifelse(GEOGRAPHY_TYPE == "regions", GEOGRAPHY_NAME, ""),
    `Occupation minor group` = ifelse(C_OCCPUK11H_0_TYPE == "3-digit occupation", C_OCCPUK11H_0_NAME,""),
    `Occupation unit group` = ifelse(C_OCCPUK11H_0_TYPE == "4-digit occupation",  C_OCCPUK11H_0_NAME, "")) %>% 
  rename(count = OBS_VALUE,
         `Observation_status` = OBS_STATUS_NAME) %>% 
  select(DATE_CODE, 
         Country, Region, 
         `Occupation minor group`, `Occupation unit group`, 
         GEOGRAPHY_CODE,
         `Observation_status`,
         count)

# make sure Occupation minor group is correct for each occupation unit group
occupations_filled <- employment_data_clean %>% 
  mutate(`Occupation minor group` = ifelse(`Occupation unit group` != "", 
                                           substr(`Occupation unit group`, 1, 3), 
                                           `Occupation minor group`)) %>% 
  left_join(occupation_lookup, by = c("Occupation minor group" = "code")) %>% 
  mutate(`Occupation minor group` = ifelse(str_length(`Occupation minor group`) == 3, 
                                           minor,
                                           as.character(`Occupation minor group`))) %>% 
  select(-minor)

# get rid of vets from the count of health professionals
vets <- occupations_filled %>% 
  filter(`Occupation unit group` == "2216 Veterinarians") %>% 
  rename(vet_count = count) %>% 
  mutate(vet_count = ifelse(is.na(vet_count), 0, vet_count)) %>% 
  select(-c(`Occupation unit group`, Observation_status, GEOGRAPHY_CODE))

non_vets <- occupations_filled %>% 
  filter(`Occupation unit group` != "2216 Veterinarians") %>% 
  left_join(vets, by = c("DATE_CODE", "Country", "Region",
                         "Occupation minor group")) %>% 
  # subtract the vet count from the minor group total (health professionals)
  mutate(count = ifelse(`Occupation minor group` == "221 Health Professionals" &
                          `Occupation unit group` == "",
                        count - vet_count, count))

# # counts are small so:
# #        should we remove region by unit group?
# reduced_disaggregations <- non_vets %>% 
#   mutate(remove = ifelse(Region != "" & 
#                            `Occupation unit group` != "", TRUE, FALSE)) %>%
#   filter(remove == FALSE) %>% 
#   select(-remove)
reduced_disaggregations <- non_vets

#----------------------------------------------------------------------------
population_data_clean <- population_data %>% 
  filter(MEASURES_NAME == "Value" &
           GENDER_NAME == "Total" &
           C_AGE_NAME == "All Ages") %>%  # don't need confidence intervals
  # split the geographies so country and region are in separate columns
  # and the occupation codes into minor group and unit group 
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "regions", GEOGRAPHY_NAME, "")) %>% 
  rename(population = OBS_VALUE) %>% 
  mutate(DATE_CODE = as.character(DATE_CODE)) %>% 
  select(DATE_CODE, 
         Country, Region, 
         population)

# calculate density
density <- reduced_disaggregations %>% 
  # We are using Jan to Dec data so can remove the month from the date code 
  mutate(Year = substr(DATE_CODE, 1, 4)) %>% 
  left_join(population_data_clean, by = c("Year" = "DATE_CODE", "Country", "Region")) %>% 
  mutate(Value = (count/population) * 10000)
  
# put in csv format
csv_formatted <- density %>% 
  mutate(Country = ifelse(Country == "United Kingdom", "", Country)) %>% 
  arrange(Country, Region, `Occupation unit group`, `Occupation minor group`) %>% 
  rename(`Observation status` = Observation_status,
         GeoCode = GEOGRAPHY_CODE) %>% 
  select(Year, `Occupation minor group`, `Occupation unit group`,
         Country, Region, GeoCode, `Observation status`, Value) 


