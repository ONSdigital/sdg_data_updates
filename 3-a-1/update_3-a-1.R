# date: 20/02/2023
# author: Katie Uzzell

# create csv_outputs for all relevant tables in source data - this is currently 
# tables 1, 2, 7, 10, and 11 but potential to report more in future

source("country_age_sex.R")
source("england_region_age_sex.R")
source("country_SEC.R")
source("ethnicity_sex_country.R")
source("country_COB.R")

combined_data <- list.files(path = "./CSVs",  
                       pattern = "*.csv", full.names = TRUE) %>% 
  lapply(read_csv) %>%                             
  bind_rows      

csv_output <- combined_data %>% 
  select("Year", "Series", "Sex","Age group", "Country", "Region of England", "Socio-economic group", "Ethnicity", "Country of birth", "Units", 
         "Unit multiplier", "Observation status", "Value") %>% 
  rename("Age" = "Age group",
       "Region" = "Region of England",
       "Socio-economic classification" = "Socio-economic group")

csv_output <- csv_output %>% replace_na(list(Country = "England"))

csv_output <- sapply(csv_output, as.character)
csv_output[is.na(csv_output)] <- ""
csv_output[csv_output == "Persons"] <- ""
csv_output[csv_output == "Women"] <- "Female"
csv_output[csv_output == "Men"] <- "Male"
csv_output[csv_output == "18-24"] <- "18 to 24"
csv_output[csv_output == "25-34"] <- "25 to 34"
csv_output[csv_output == "35-44"] <- "35 to 44"
csv_output[csv_output == "45-54"] <- "45 to 54"
csv_output[csv_output == "55-64"] <- "55 to 64"
csv_output[csv_output == "65+"] <- "65 and over"
csv_output[csv_output == "All 18+"] <- ""
csv_output[csv_output == "East of England"] <- "East"
csv_output[csv_output == "United Kingdom"] <- ""

  


