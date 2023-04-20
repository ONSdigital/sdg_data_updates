# date: 20/02/2023
# author: Katie Uzzell

# read in data -----------------------------------------------------------------

table_2_source_data <- get_type1_data(header_row, filename, "Table_2")

# format data ------------------------------------------------------------------

table_2_data <- extract_data(table_2_source_data, header_row)

table_2_data <- table_2_data %>% select(-ends_with(c("UCL", "LCL"))) 

table_2_data <- table_2_data %>% select(contains(c("Sex", 
                                                   "Region", 
                                                   "Age group", 
                                                   "Current smokers"))) 

table_2_data <- table_2_data %>% select(-"Region code")

table_2_data <- table_2_data %>% 
  pivot_longer(-c("Sex", "Region of England", "Age group"), 
               names_to = "Year", 
               values_to = "Value")

table_2_data$Year = substr(table_2_data$Year,1,4)  

table_2_data <- table_2_data %>% 
  mutate("Units" = "Percentage (%)",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value", # make sure to check source data and manually change this if data is provisional etc.
         "Series" = "Percentage of people who are current cigarette smokers aged 18 years and older") %>%  
  select("Year", "Series", "Sex", "Region of England", "Age group", "Units", 
         "Unit multiplier", "Observation status", "Value")

existing_output_files <- list.files()
csv_folder_exists <- ifelse(csv_folder %in% existing_output_files, TRUE, FALSE)

if (csv_folder_exists == FALSE) {
  dir.create(csv_folder)
}

write_csv(table_2_data, "./CSVs/table_2_data.csv")