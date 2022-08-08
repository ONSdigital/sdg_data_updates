aid_types <- oda_renamed %>% 
  mutate(
    aid_type = case_when(
      between(sector_purpose_code, 11200, 11299) ~ "basic education",
      between(sector_purpose_code, 12200, 12299) ~ "basic health",
      between(sector_purpose_code, 14000, 14099) ~ "water supply and sanitation",
      sector_purpose_code == 16050 ~ "basic social services",
      sector_purpose_code == 52010 ~ "development food aid")) %>% 
  filter(!is.na(aid_type))

disaggregations <- aid_types %>% 
  group_by(year, aid_type) %>% 
  summarise(gbp = sum(oda)) 

headlines <- disaggregations %>% 
  group_by(year) %>% 
  summarise(gbp = sum(gbp))
  
gbp_data <- bind_rows(disaggregations, headlines) 

# calculate % of GNI -----------------------------------------------------------
joined_tables <- gni_data %>% 
  janitor::clean_names() %>% 
  select(obs_time, obs_value) %>% 
  mutate(obs_time = as.integer(obs_time)) %>% 
  rename(year = obs_time) %>% 
  right_join(gbp_data, by = "year")

percent_gni <- joined_tables %>% 
  mutate(value = (gbp/1000)/obs_value*100) # GNI is in millions, while ODA is in thousands

names(percent_gni) <- str_to_sentence(names(percent_gni))

csv_1a1 <- percent_gni %>% 
  mutate(Units = "Percentage (%)",
         Series = "Official development assistance grants for poverty reduction (percentage of GNI)",
         `Observation status` = "Normal value")  %>% 
  select(Year, Series, Aid_type, 
         Units, `Observation status`, Value) %>% 
  replace(is.na(.), "") %>% 
  rename(`Poverty reduction aid type` = Aid_type)

rm(aid_types, disaggregations, headlines, gbp_data, joined_tables, percent_gni)

scripts_run <- c(scripts_run, "1-a-1")
