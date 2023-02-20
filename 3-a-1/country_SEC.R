# date: 20/02/2023
# author: Katie Uzzell

# read in data -----------------------------------------------------------------

table_7_source_data <- get_type1_data(header_row, filename, "Table_7")

# format data ------------------------------------------------------------------

table_7_data <- extract_data(table_7_source_data, header_row)

table_7_data <- table_7_data %>% select(-ends_with(c("UCL", "LCL"))) 

#### NEED TO FIND A BETTER WAY TO REMOVE \n[note 11] in column name ####

colnames(table_7_data)[colnames(table_7_data) == "Socio-economic group \n[note 11]"] = "Socio-economic group"

table_7_data <- table_7_data %>% select(contains(c("Country", 
                                                   "Socio-economic group",
                                                   "Current smokers"))) 

table_7_data <- table_7_data %>% select(-"Country code")

table_7_data <- table_7_data %>% 
  pivot_longer(-c("Country", "Socio-economic group"), 
               names_to = "Year", 
               values_to = "Value")

table_7_data$Year = substr(table_7_data$Year,1,4)  

table_7_data <- table_7_data %>% 
  mutate("Units" = "Percentage",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>%  # make sure to check source data and manually change this if data is provisional etc.
  select("Year", "Country", "Socio-economic group", "Units", 
         "Unit multiplier", "Observation status", "Value")

write_csv(table_7_data, "./Output/CSVs/table_7_data.csv")
