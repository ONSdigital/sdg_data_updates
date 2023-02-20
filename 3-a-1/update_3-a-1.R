# date: 20/02/2023
# author: Katie Uzzell

# create csv_outputs for all relevant tables in source data - this is currently 
# tables 1, 2, 7, 10, and 11 but potential to report more in future

source("country_age_sex.R")
source("england_region_age_sex.R")
source("country_SEC.R")
source("ethnicity_sex_country.R")
source("country_COB.R")

combined_data <- list.files(path = "./Output/CSVs",  
                       pattern = "*.csv", full.names = TRUE) %>% 
  lapply(read_csv) %>%                             
  bind_rows                                         

csv_output <- combined_data %>% 
  select("Year", "Sex","Age group", "Country", "Region of England", "Socio-economic group", "Ethnicity", "Country of birth", "Units", 
         "Unit multiplier", "Observation status", "Value")

csv_output <- sapply(csv_output, as.character)
csv_output[is.na(csv_output)] <- ""
csv_output[csv_output == "Persons"] <- ""
csv_output[csv_output == "Women"] <- "Female"
csv_output[csv_output == "Men"] <- "Male"
