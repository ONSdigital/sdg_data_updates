population_data <- read.csv(nomis_population_link)
employment_data <- read.csv(nomis_employment_link) %>% 
  mutate(across(where(is.factor), as.character)) 

# get the months the years run from and to (to use in QA)
months <- as.character(unique(employment_data$DATE_NAME))
months_no_years <- gsub('[[:digit:]]+', '', months)
unique_months <- unique(months_no_years)

minor_occupations <- unique(employment_data$C_OCCPUK11H_0_NAME[employment_data$C_OCCPUK11H_0_TYPE == "3-digit occupation"])
occupation_lookup <- data.frame(minor = minor_occupations,
                                code = substring(minor_occupations, 1, 3)) %>% 
  mutate(across(where(is.factor), as.character))

employment_data_clean <- employment_data %>% 
  filter(MEASURES_NAME == "Value") %>%  # don't need confidence intervals
  # split the geographies so country and region are in separate columns
  # and the occupation codes into minor group and unit group 
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "regions" ~ "England",
    TRUE ~ ""),
    
    Region = ifelse(GEOGRAPHY_TYPE == "regions", GEOGRAPHY_NAME, ""),
    `Occupation minor group` = ifelse(C_OCCPUK11H_0_TYPE == "3-digit occupation", C_OCCPUK11H_0_NAME,""),
    `Occupation unit group` = ifelse(C_OCCPUK11H_0_TYPE == "4-digit occupation",  C_OCCPUK11H_0_NAME, "")) %>% 
  rename(Value = OBS_VALUE,
         `Observation_status` = OBS_STATUS_NAME,
         Sex = C_SEX_NAME) %>% 
  select(DATE_CODE, 
         Country, Region, 
         Sex, 
         `Occupation minor group`, `Occupation unit group`, 
         GEOGRAPHY_CODE,
         `Observation_status`,
         Value)

# make sure Occupation minor group is correct for each occupation unit group
occupations_filled <- employment_data_clean %>% 
  mutate(`Occupation minor group` = ifelse(`Occupation unit group` != "", 
                                           substr(`Occupation unit group`, 1, 3), 
                                           `Occupation minor group`)) %>% 
  left_join(occupation_lookup, by = c("Occupation minor group" = "code")) %>% 
  mutate(test = str_length(`Occupation minor group`)) %>% 
  mutate(`Occupation minor group` = ifelse(str_length(`Occupation minor group`) == 3, 
                                           minor,
                                           as.character(`Occupation minor group`))) %>% 
  select(-minor)

# get rid of dentists from the count of health professionals
# calculate density
# put in csv format