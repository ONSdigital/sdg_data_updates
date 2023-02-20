# date: 20/02/2023
# author: Katie Uzzell

# read in data -----------------------------------------------------------------

table_10_source_data <- get_type1_data(header_row, filename, "Table_10")

# format data ------------------------------------------------------------------

table_10_data <- extract_data(table_10_source_data, header_row)

table_10_data <- table_10_data %>% select(-ends_with(c("UCL", "LCL"))) 

#### NEED TO FIND A BETTER WAY TO REMOVE \n[note 12] in column name ####

colnames(table_10_data)[colnames(table_10_data) == "Ethnicity \n[note 12]"] = "Ethnicity"

table_10_data <- table_10_data %>% select(contains(c("Sex", 
                                                   "Country", 
                                                   "Ethnicity", 
                                                   "Current smokers"))) 

table_10_data <- table_10_data %>% select(-"Country code")

table_10_data <- table_10_data %>% 
  pivot_longer(-c("Sex", "Country", "Ethnicity"), 
               names_to = "Year", 
               values_to = "Value")

table_10_data$Year = substr(table_10_data$Year,1,4)  

table_10_data <- table_10_data %>% 
  mutate("Units" = "Percentage",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>%  # make sure to check source data and manually change this if data is provisional etc.
  select("Year", "Sex", "Country", "Ethnicity", "Units", 
         "Unit multiplier", "Observation status", "Value")

write_csv(table_10_data, "./Output/CSVs/table_10_data.csv")
