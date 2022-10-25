# date: 24/10/2022


required_data <- janitor::clean_names(dat) %>% 
  select(time_period,
         indicator_name, 
         area_code, area_name, area_type, 
         sex, age,
         category_type, category, 
         value,
         value_note) %>% 
  rename(series = indicator_name,
         year = time_period)

# UA plus district is lower tier local authority
# County plus district is upper tier local authority
geographies <- required_data %>% 
  filter(tolower(area_type) %in% c("ua", "district", "region", "england") &
           !grepl("county", tolower(category_type))) %>% 
  mutate(area_type = 
           ifelse(tolower(area_type) %in% c("ua", "district"), 
                  "LA", area_type),
         area_name = str_remove(area_name, "region")
         ) %>% 
  pivot_wider(names_from = area_type,
              values_from = area_name) %>% 
  mutate(Region = ifelse(Region == "Yorkshire and the Humber",
                         "Yorkshire and The Humber", Region))

deprivation_note <- geographies %>% 
  filter(!is.na(category_type) & category_type != "") %>% 
  distinct(year, category_type)

deprivation <- geographies %>% 
  mutate(category = case_when(
    grepl("Most", category) ~ "Decile 10 (most deprived)",
    grepl("Second mo", category) ~ "Decile 9",
    grepl("Third mo", category) ~ "Decile 8",
    grepl("Fourth mo", category) ~ "Decile 7",
    grepl("Fifth mo", category) ~ "Decile 6",
    grepl("Fifth le", category) ~ "Decile 5",
    grepl("Fourth le", category) ~ "Decile 4",
    grepl("Third le", category) ~ "Decile 3",
    grepl("Second le", category) ~ "Decile 2",
    grepl("Least", category) ~ "Decile 1 (least deprived)",
    TRUE ~ as.character(category)
  )) %>% 
  filter(!grepl("ethnic", tolower(category_type)) &
           !grepl("sex", tolower(category))) %>% 
  rename(`Deprivation decile` = category) 

# format data for csv file -----------------------------------------------------
csv_formatted <- deprivation %>%
  rename(`Observation status` = value_note,
         GeoCode = area_code,
         `Local Authority` = LA,
         Year = year,
         Value = value,
         Series = series) %>% 
  mutate(
    `Observation status` = case_when(
      `Observation status` == "Value missing in source data" ~ "Missing value",
      `Observation status` == "" ~ "Normal value",
      TRUE ~ as.character(`Observation status`))
  ) %>%
  mutate(Value = round(Value, 2)) %>% 
  arrange(`Local Authority`, Region, `Deprivation decile`, Year) %>%
  select(Year, Series, Region, `Local Authority`, `Deprivation decile`,
         GeoCode, `Observation status`, Value)  

