
chosen_type_of_aid <-  oda_renamed %>% 
  filter(aid_code == type_of_aid_code_4b1) %>% 
  mutate(country_income_classification = ifelse(
    grepl("unallocated", country_income_classification)== TRUE |
      country_income_classification == "0",
    "Unspecified", country_income_classification))

by_sector <- chosen_type_of_aid %>% 
  group_by(year, sector) %>% 
  summarise(value = sum(value))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(value))

by_education_type <- chosen_type_of_aid %>% 
  filter(sector == "Education") %>% # make this more robust
  group_by(year, type_of_study) %>% 
  summarise(value = sum(value)) %>% 
  mutate(sector = "Education")

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(by_sector, by_cic, by_education_type, total) %>% 
  mutate(Units = "GBP (£ thousands)")

constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv_4b1 <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  select(Year, Sector, Country_income_classification, Type_of_study, 
         Units, Value) %>% 
  replace(is.na(.), "")

rm(by_sector, by_cic, by_education_type, total, chosen_type_of_aid)

scripts_run <- c(scripts_run, "4-b-1")