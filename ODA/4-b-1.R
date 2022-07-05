
chosen_type_of_aid <-  filter(oda_renamed, Aid_code == type_of_aid_code)

by_sector <- chosen_type_of_aid %>% 
  group_by(year, Sector) %>% 
  summarise(Value = sum(Value))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, Country_income_classification) %>% 
  summarise(Value = sum(Value))

by_education_type <- chosen_type_of_aid %>% 
  filter(Sector == "Education") %>% # make this more robust
  group_by(year, Type_of_study) %>% 
  summarise(Value = sum(Value))

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(Value = sum(Value))

csv_4b1 <- bind_rows(by_sector, by_cic, by_education_type, total)  