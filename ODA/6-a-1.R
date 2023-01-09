agri <- oda_renamed %>% 
  filter(sector_purpose_code == crs_code_6a1) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(gross_oda, na.rm = TRUE)) %>% 
  mutate(crs_code = "Agricultural water resources")

water <- oda_renamed %>% 
  filter(broad_sector_code == broad_sector_code_6a1) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(gross_oda, na.rm = TRUE))  %>% 
  mutate(crs_code = "Water Supply and Sanitation")

# for this indicator we don't report the water/agri disaggregations
disaggregations <- agri %>% 
  bind_rows(water) %>%   
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(value)) 

headline <- disaggregations %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(disaggregations, 
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
  mutate(Series = "Total official development assistance (gross disbursement) for water supply and sanitation, by recipient countries",
         `Observation status` = "Normal value") %>% 
  select(Year, Series, Country_income_classification,
         `Observation status`, Units, Value) %>% 
  arrange(Year, Country_income_classification) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification)

rm(agri, water, disaggregations, headline,
   gbp_data, constant_usd_data)

scripts_run <- c(scripts_run, "6-a-1")
