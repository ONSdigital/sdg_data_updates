# QA script for 4-b-1

dat <- read.csv(paste0(input_folder, "/", filename))
names(dat) <- tolower(names(dat))

rename_column <- function(dat, patterns, new_name){
  patterns <- patterns
  column <- which(apply(sapply(patterns, grepl, names(dat)), 1, all) == TRUE)
  names(dat)[column] <- new_name
  return(dat)
}

dat_new_names <- rename_column(dat, c("extend", "amount"), "Value") 
dat_new_names <- rename_column(dat_new_names, c("income", "group"), "Country_income_classification")
dat_new_names <- rename_column(dat_new_names, c("type", "aid", "code"), "Aid_code") 
dat_new_names <- rename_column(dat_new_names, c("type", "aid", "text"), "Aid_description") 
dat_new_names <- rename_column(dat_new_names, c("sid", "sector"), "Sector")
dat_new_names <- rename_column(dat_new_names, c("sector", "purpose", "text"), "Type_of_study")
  
chosen_type_of_aid <-  filter(dat_new_names, Aid_code == type_of_aid_code)

by_sector <- chosen_type_of_aid %>% 
  group_by(year, Sector) %>% 
  summarise(Value = sum(Value))

by_cic <- chosen_type_of_aid %>% 
  group_by(year, Country_income_classification) %>% 
  summarise(Value = sum(Value))

by_education_type <- chosen_type_of_aid %>% 
  filter(Sector == "Education") %>% 
  group_by(year, Type_of_study) %>% 
  summarise(Value = sum(Value))

total <- chosen_type_of_aid %>% 
  group_by(year) %>% 
  summarise(Value = sum(Value))

csv_data <- bind_rows(by_sector, by_cic, by_education_type, total)  
