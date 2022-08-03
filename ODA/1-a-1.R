aid_types <- oda_renamed %>% 
  mutate(
    aid_type = case_when(
      between(sector_purpose_code, 11200, 11299) ~ "basic education",
      between(sector_purpose_code, 12200, 12299) ~ "basic health",
      between(sector_purpose_code, 14000, 14099) ~ "water supply and sanitation",
      sector_purpose_code == 16050 ~ "basic social services",
      sector_purpose_code == 52010 ~ "development food aid"),
    crs_code = case_when(
      between(sector_purpose_code, 11200, 11299) ~ "112xx",
      between(sector_purpose_code, 12200, 12299) ~ "122xx",
      between(sector_purpose_code, 14000, 14099) ~ "140xx",
      sector_purpose_code == 16050 ~ "16050",
      sector_purpose_code == 52010 ~ "52010")) %>% 
  filter(!is.na(aid_type))

disaggregations <- aid_types %>% 
  group_by(year, aid_type, crs_code) %>% 
  summarise(value = sum(oda)) 

headlines <- disaggregations %>% 
  group_by(year) %>% 
  summarise(value = sum(value))
  
gbp_data <- bind_rows(disaggregations, headlines) %>% 
  mutate(Units = "GBP (£ thousands)")

constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)

names(gbp_data) <- str_to_sentence(names(gbp_data))
names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))

csv_1a1 <- gbp_data %>% 
  bind_rows(constant_usd_data) %>% 
  select(Year, Aid_type, Crs_code,  
         Units, Value) %>% 
  replace(is.na(.), "") %>% 
  rename(`Aid type` = Aid_type,
         `CRS code` = Crs_code)

rm(by_sector, by_cic, by_education_type, total, chosen_type_of_aid)

scripts_run <- c(scripts_run, "1-a-1")