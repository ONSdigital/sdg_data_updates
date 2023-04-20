
chosen_type_of_aid <- oda_renamed %>% 
  filter(aid_code == type_of_aid_code_4b1) %>% 
  mutate(country_income_classification = ifelse(
    grepl("unallocated", country_income_classification)== TRUE |
      country_income_classification == "0",
    "Unspecified", country_income_classification))

by_sector <- chosen_type_of_aid %>% 
  group_by(year, sector) %>% 
  summarise(value = sum(gross_oda))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(gross_oda))

by_education_type <- chosen_type_of_aid %>% 
  filter(sector == "Education") %>% # make this more robust
  group_by(year, type_of_study) %>% 
  summarise(value = sum(gross_oda)) %>% 
  mutate(sector = "Education") %>% 
  # education headline is already created in by_sector so prevent duplication:
  filter(type_of_study != "")

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(value = sum(gross_oda))

gbp_data <- bind_rows(by_sector, by_cic, by_education_type, total) %>% 
  mutate(Units = "GBP (£ thousands)")

constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  mutate(Series = "Total official flows for scholarships, by recipient countries") %>% 
  replace(is.na(.), "") %>% 
  mutate(
    Type_of_study = ifelse(
      grepl("Upper Secondary Education", Type_of_study), 
      "Upper secondary education", Type_of_study),
    Sector = ifelse(
      grepl("OTHER SOCIAL INFRASTRUCTURE AND SERVICES", Sector),
      "Other social infrastructure and services", Sector),
    `Observation status` = "Normal value") %>% 
  rename(`Country income classification` = Country_income_classification,
         `Type of study` = Type_of_study) %>% 
  select(Year, Series, `Country income classification`, Sector, `Type of study`, 
         Units, `Observation status`, Value)

csv$Sector <- str_to_sentence(csv$Sector)

rm(by_sector, by_cic, by_education_type, total, chosen_type_of_aid)

scripts_run <- c(scripts_run, "4-b-1")