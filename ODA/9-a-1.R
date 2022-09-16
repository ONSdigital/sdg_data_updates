
infrastructure <- oda_renamed %>% 
  mutate(infrastructure = grepl(tolower(sid_sector_9a1), tolower(sector))) %>% 
  filter(infrastructure == TRUE) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(net_oda, na.rm = TRUE))

headline <- infrastructure %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(infrastructure, 
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
  mutate(Series = "Net Official Development Assistance (ODA) to infrastructure",
         `Observation status` = "Definition differs") %>% 
  select(Year, Series, Country_income_classification,
         `Observation status`, Units, Value) %>% 
  arrange(Year, Country_income_classification) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification)

rm(infrastructure, headline,
   gbp_data, constant_usd_data)

scripts_run <- c(scripts_run, "9-a-1")
