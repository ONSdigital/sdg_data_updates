
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

# # convert to constant USD - make this a function
# # convert to USD
# exchange_rates <- tidyxl::xlsx_cells(paste0(input_folder, "/", exchange_filename))
# 
# exchange_heading_row <- which(!is.na(exchange_rates$numeric))[1]
# 
# exchange_data <- exchange_rates %>% 
#   filter(row >= exchange_heading_row) %>% 
#   behead("left", country) %>% 
#   behead("up", year) %>% 
#   filter(!is.na(numeric)) %>% 
#   select(year, country, numeric)
# 
# uk_exchange_data <- exchange_data %>% 
#   mutate(country = tolower(country)) %>% 
#   filter(country %in% c("uk", "united kingdom")) %>% 
#   rename(exchange_rate = numeric) %>% 
#   select(year, exchange_rate)

usd_data <- gbp_data %>% 
  left_join(uk_exchange_data, by = "year" ) %>% 
  mutate(Value = Value/exchange_rate) %>% 
  select(-exchange_rate)

# # make it constant USD
# deflators <- tidyxl::xlsx_cells(paste0(input_folder, "/", deflators_filename),
#                                 sheets = "Deflators")
# 
# heading_row <- which(!is.na(deflators$numeric))[1]
# 
# deflators_data <- deflators %>% 
#   filter(row >= heading_row) %>% 
#   behead("left", country) %>% 
#   behead("up", year) %>% 
#   filter(!is.na(numeric)) %>% 
#   select(year, country, numeric)
# 
# uk_deflators <- deflators_data %>% 
#   mutate(country = tolower(country)) %>% 
#   filter(country %in% c("uk", "united kingdom")) %>% 
#   rename(deflator = numeric) %>% 
#   select(year, deflator)

constant_usd_data <- usd_data %>% 
  left_join(uk_deflators, by = "year") %>% 
  mutate(Value = (Value/deflator)*100,
         Units = "Constant USD ($ thousands)") %>% 
  select(-deflator) 

# join together
csv_data <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  select(year, Country_income_classification, Units, Value)