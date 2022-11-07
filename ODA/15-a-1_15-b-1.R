# Series using data from the main source (15-a-1a) ----
biodiversity <- oda_renamed %>% 
  filter(sector_purpose_code == crs_code_15a1_15b1) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(gross_oda, na.rm = TRUE)) 

headline <- biodiversity %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(biodiversity, 
                      headline) %>% 
  mutate(Units = "GBP (£ thousands)",
         country_income_classification = ifelse(
           grepl("unallocated", country_income_classification)== TRUE |
             country_income_classification == "0",
           "Unspecified", country_income_classification)
  )

# could easily add USD here if desired. See e.g. code for 6-a-1

names(gbp_data) <- str_to_sentence(names(gbp_data))

series_a <- gbp_data %>% 
  mutate(Series = "Total official development assistance for biodiversity, by recipient countries",
                   `Observation status` = "Normal value") %>% 
  select(Year, Series, Country_income_classification,
         `Observation status`, Units, Value) 

# Series using data specific to 15-a-1/15-b-1 (15-a-1b/15-b-1b) ----
series_b <- biodiversity_data %>% 
  mutate(
    Units = case_when(
      VAR == "BASE_NC" ~ "GBP (£ Millions)",
      VAR == "BASE_USD" ~ "USD ($ Millions)",
      VAR == "BASE_REV" ~ "Percentage (%)",
      VAR == "BASE_GDP" ~ "Percent of GDP (%)"
    )) %>% 
  mutate(
    Series = case_when(
      VAR == "BASE_NC" | VAR == "BASE_USD" ~ "Tax revenue from biodiversity-relevant taxes",
      VAR == "BASE_REV" ~ "Tax revenue from biodiversity-relevant taxes out of total tax revenue",
      VAR == "BASE_GDP" ~ "Tax revenue from biodiversity-relevant taxes"
    ),
    `Observation status` = "Estimated value",
    obsTime = as.integer(obsTime)) %>% 
  # Obs status is stated as 'lower end estimate' in the OECD dataset documentation 
  # once the selections are made as described in source 2 of 15-a-1. To read, 
  # go to Export > Related files
  rename(Year = obsTime,
         Value = obsValue) %>% 
  select(Year, Series, `Observation status`, Units, Value)

# Bind data for both series ----
csv <- bind_rows(series_a, series_b) %>% 
  arrange(Year, Country_income_classification) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification)

rm(biodiversity, headline, gbp_data, 
   series_a, seroes_b)

scripts_run <- c(scripts_run, "15-a-1_15-b-1")
