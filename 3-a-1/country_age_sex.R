# date: 20/02/2023
# author: Katie Uzzell

# read in data -----------------------------------------------------------------

table_1_source_data <- get_type1_data(header_row, filename, "Table_1")

# format data ------------------------------------------------------------------

table_1_data <- extract_data(table_1_source_data, header_row)

table_1_data <- table_1_data %>% select(-ends_with(c("UCL", "LCL"))) 

table_1_data <- table_1_data %>% select(contains(c("Sex", 
                                                   "Country", 
                                                   "Age group", 
                                                   "Current smokers"))) 

table_1_data <- table_1_data %>% select(-"Country code")

table_1_data <- table_1_data %>% 
  pivot_longer(-c("Sex", "Country", "Age group"), 
               names_to = "Year", 
               values_to = "Value")
  
table_1_data$Year = substr(table_1_data$Year,1,4)  

table_1_data <- table_1_data %>% 
  mutate("Units" = "Percentage",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>%  # make sure to check source data and manually change this if data is provisional etc.
  select("Year", "Sex", "Country", "Age group", "Units", 
         "Unit multiplier", "Observation status", "Value")

write_csv(table_1_data, "./Output/CSVs/table_1_data.csv")
