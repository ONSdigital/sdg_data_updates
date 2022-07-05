# convert to constant USD - make this a function
# convert to USD
exchange_rates <- tidyxl::xlsx_cells(paste0(input_folder, "/", exchange_filename))

exchange_heading_row <- which(!is.na(exchange_rates$numeric))[1]

exchange_data <- exchange_rates %>% 
  filter(row >= exchange_heading_row) %>% 
  behead("left", country) %>% 
  behead("up", year) %>% 
  filter(!is.na(numeric)) %>% 
  select(year, country, numeric)

uk_exchange_data <- exchange_data %>% 
  mutate(country = tolower(country)) %>% 
  filter(country %in% c("uk", "united kingdom")) %>% 
  rename(exchange_rate = numeric) %>% 
  select(year, exchange_rate)
# ----
# make it constant USD
deflators <- tidyxl::xlsx_cells(paste0(input_folder, "/", deflators_filename),
                                sheets = "Deflators")

heading_row <- which(!is.na(deflators$numeric))[1]

deflators_data <- deflators %>% 
  filter(row >= heading_row) %>% 
  behead("left", country) %>% 
  behead("up", year) %>% 
  filter(!is.na(numeric)) %>% 
  select(year, country, numeric)

uk_deflators <- deflators_data %>% 
  mutate(country = tolower(country)) %>% 
  filter(country %in% c("uk", "united kingdom")) %>% 
  rename(deflator = numeric) %>% 
  select(year, deflator)