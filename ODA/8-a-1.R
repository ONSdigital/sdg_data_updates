
chosen_type_of_aid <-  oda_renamed %>% 
  filter(broad_sector_code == broad_sector_code_8a1) %>% 
  mutate(gross_oda = as.numeric(as.character(gross_oda))) %>% 
  mutate(country_income_classification = ifelse(
    grepl("unallocated", country_income_classification)== TRUE |
      country_income_classification == "0",
    "Unspecified", country_income_classification))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(gross_oda, na.rm = TRUE))

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(value = sum(gross_oda, na.rm = TRUE))

gbp_data <- bind_rows(by_cic, total) %>% 
  mutate(units = "GBP (£ thousands)") 

constant_usd_data <- gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  rename(`Country income classification` = Country_income_classification) %>% 
  mutate(`Observation status` = "Normal value") %>% 
  replace(is.na(.), "") %>% 
  select(Year, `Country income classification`, Units, `Observation status`, Value)

scripts_run <- c(scripts_run, "8-a-1")