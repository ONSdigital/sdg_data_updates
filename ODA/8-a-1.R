
chosen_type_of_aid <-  oda_renamed %>% 
  filter(Broad_sector_code == broad_sector_code_8a1) %>% 
  mutate(Value = as.numeric(as.character(Value)))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, Country_income_classification) %>% 
  summarise(Value = sum(Value, na.rm = TRUE))

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(Value = sum(Value, na.rm = TRUE))

gbp_data <- bind_rows(by_cic, total) %>% 
  mutate(Units = "GBP (£ thousands)") 

constant_usd_data <- gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv_8a1 <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  select(Year, Country_income_classification, Units, Value) %>% 
  replace(is.na(.), "")

scripts_run <- c(scripts_run, "8-a-1")