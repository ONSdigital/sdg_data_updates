disaggregations <- oda_renamed %>% 
  filter(broad_sector_code == broad_sector_code_2a2) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(oda)) %>% 
  mutate(country_income_classification = ifelse(
    grepl("unallocated", country_income_classification)== TRUE |
      country_income_classification == "0",
    "Unspecified", country_income_classification
  ))

headlines <- disaggregations %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(disaggregations, headlines) %>% 
  mutate(Units = "GBP (£ thousands)")

constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  mutate(Series = "Total official flows (disbursements) for agriculture, by recipient countries",
         `Observation status` = "Definition differs") %>% 
  select(Year, Series, Country_income_classification,  
          `Observation status`, Units, Value) %>% 
  arrange(Year, Country_income_classification) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification)

rm(disaggregations, headlines, gbp_data, constant_usd_data)

scripts_run <- c(scripts_run, "2-a-2")