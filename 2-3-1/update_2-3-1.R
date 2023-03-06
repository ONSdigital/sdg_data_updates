# author: Katie Uzzell
# date: 27/02/2023

# Code to automate data update for indicator 2-3-1 (Total factor and labour 
# productivity of the United Kingdom agriculture industry)

# read in data 

agriprod_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

agriprod_main_data <- extract_data(agriprod_source_data, header_row)

# rename column 1

colnames(agriprod_main_data) [1] <- "Productivity type"

agriprod_main_data <- agriprod_main_data %>%
  mutate(across(everything(), as.character))

# select necessary rows

productivity_data <- agriprod_main_data[agriprod_main_data$`Productivity type` %in% 
                                           c("Total factor productivity (11 divided by 25)",
                                             "Productivity by intermediate consumption (11 divided by 21)",
                                             "Productivity by capital consumption (11 divided by 22)",
                                             "Productivity by labour (11 divided by 23)",
                                             "Productivity by land (11 divided by 24)"),]

productivity_data[productivity_data == 'Total factor productivity (11 divided by 25)'] <- 'Total factor productivity'
productivity_data[productivity_data == 'Productivity by intermediate consumption (11 divided by 21)'] <- 'Productivity by intermediate consumption'
productivity_data[productivity_data == 'Productivity by capital consumption (11 divided by 22)'] <- 'Productivity by capital consumption'
productivity_data[productivity_data == 'Productivity by labour (11 divided by 23)'] <- 'Productivity by labour'
productivity_data[productivity_data == 'Productivity by land (11 divided by 24)'] <- 'Productivity by land'

productivity_data <- productivity_data %>% 
  rename_column(primary = "Productivity type", 
                new_name = "Productivity")

inputs_data <- agriprod_main_data[agriprod_main_data$`Productivity type` %in% 
                                          c("23 All Labour",
                                            "25 All Inputs and Entrepreneurial Labour"),]

inputs_data[inputs_data == '23 All Labour'] <- 'Labour inputs'
inputs_data[inputs_data == '25 All Inputs and Entrepreneurial Labour'] <- 'All inputs'

inputs_data <- inputs_data %>% 
  rename_column(primary = "Productivity type", 
                new_name = "Inputs")

outputs_data <- agriprod_main_data[agriprod_main_data$`Productivity type` %in% 
                                          c("11 All outputs"),]

outputs_data[outputs_data == '11 All outputs'] <- 'All outputs'

outputs_data <- outputs_data %>% 
  rename_column(primary = "Productivity type", 
                new_name = "Outputs")

# format into CSVs and join together

productivity_csv <- productivity_data %>% 
  pivot_longer(-c("Productivity"), names_to = "Year", values_to = "Value")

productivity_csv <- productivity_csv %>% 
  mutate("Unit measure" = "Index",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>% 
  select("Year", "Productivity", "Observation status", "Unit multiplier", "Unit measure", "Value")

inputs_csv <- inputs_data %>% 
  pivot_longer(-c("Inputs"), names_to = "Year", values_to = "Value")

inputs_csv <- inputs_csv %>% 
  mutate("Unit measure" = "Index",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>% 
  select("Year", "Inputs", "Observation status", "Unit multiplier", "Unit measure", "Value")

outputs_csv <- outputs_data %>% 
  pivot_longer(-c("Outputs"), names_to = "Year", values_to = "Value")

outputs_csv <- outputs_csv %>% 
  mutate("Unit measure" = "Index",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>% 
  select("Year", "Outputs", "Observation status", "Unit multiplier", "Unit measure", "Value")

combined_data <- bind_rows (productivity_csv, inputs_csv, outputs_csv)

csv_output <- combined_data %>% 
  select("Year", "Productivity", "Outputs", "Inputs", "Observation status", 
         "Unit multiplier", "Unit measure", "Value")

csv_output[is.na(csv_output)] <- ""
  
  
