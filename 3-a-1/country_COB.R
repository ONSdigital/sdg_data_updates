# date: 20/02/2023
# author: Katie Uzzell

# read in data -----------------------------------------------------------------

table_11_source_data <- get_type1_data(header_row, filename, "Table_11")

# format data ------------------------------------------------------------------

table_11_data <- extract_data(table_11_source_data, header_row)

table_11_data <- table_11_data %>% select(-ends_with(c("UCL", "LCL"))) 

#### NEED TO FIND A BETTER WAY TO REMOVE \n[note 11] in column name ####

colnames(table_11_data)[colnames(table_11_data) == "Country of birth \n[note 13]"] = "Country of birth"

table_11_data <- table_11_data %>% select(contains(c("Country",
                                                   "Current smokers"))) 

table_11_data <- table_11_data %>% select(-"Country code")

table_11_data <- table_11_data %>% 
  pivot_longer(-c("Country", "Country of birth"), 
               names_to = "Year", 
               values_to = "Value")

table_11_data$Year = substr(table_11_data$Year,1,4)  

table_11_data <- table_11_data %>% 
  mutate("Units" = "Percentage (%)",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value", # make sure to check source data and manually change this if data is provisional etc.
         "Series" = "Percentage of people who are current cigarette smokers aged 18 years and older") %>%
  select("Year", "Series", "Country", "Country of birth", "Units", 
         "Unit multiplier", "Observation status", "Value")

existing_output_files <- list.files()
csv_folder_exists <- ifelse(csv_folder %in% existing_output_files, TRUE, FALSE)

if (csv_folder_exists == FALSE) {
  dir.create(csv_folder)
}

write_csv(table_11_data, "./CSVs/table_11_data.csv")
