medical_research <- oda_renamed %>% 
  filter(sector_purpose_code == crs_code_3b2) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(oda)) %>% 
  mutate(crs_code = "Medical research")

basic_health <- oda_renamed %>% 
  filter(broad_sector_code == broad_sector_code_3b2) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(oda))  %>% 
  mutate(crs_code = "Basic health")

disaggregations <- medical_research %>% 
  bind_rows(basic_health)  

headline_income_type <- disaggregations %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(value))

# this isn't in the live data but not sure why 
headline_health <- disaggregations %>% 
  group_by(year, crs_code) %>% 
  summarise(value = sum(value))

headline <- disaggregations %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(disaggregations, 
                      headline_income_type, headline_health,
                      headline) %>% 
  mutate(Units = "GBP (£ thousands)",
         country_income_classification = ifelse(
           grepl("unallocated", country_income_classification)== TRUE |
             country_income_classification == "0",
           "Unspecified", country_income_classification)
         )

constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, 
                                          gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  mutate(Series = "Total official development assistance to medical research and basic heath sectors, net disbursement, by recipient countries",
         `Observation status` = "Normal value") %>% 
  select(Year, Series, Country_income_classification, Crs_code, 
         `Observation status`, Units, Value) %>% 
  arrange(Year, Country_income_classification, Crs_code) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification,
         `Aid description (CRS code)` = Crs_code)

rm(medical_research, basic_health, disaggregations,
   headline_income_type, headline,
   gbp_data, constant_usd_data)

scripts_run <- c(scripts_run, "2-a-2")