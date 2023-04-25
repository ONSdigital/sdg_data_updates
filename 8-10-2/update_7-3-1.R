# author: Katie Uzzell
# date: 25/04/2023

# Code to automate data update for indicator 8-10-2 (Percentage of adults (16 years 
# and older) with an account at a bank or other financial institution).

# read in data 

savings_investments_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

savings_investments_main_data <- extract_data(energy_source_data, header_row)







# remove unwanted columns

energy_main_data <- within(energy_main_data, rm("Sector code","Section code"))

# select only needed rows 

selected_rows <- c(1:22)

energy_main_data <- energy_main_data %>%
  slice(selected_rows)

energy_main_data <- energy_main_data %>% 
  na.omit()

# format

energy_csv <- energy_main_data %>% 
  pivot_longer(-c("Industry sector"), names_to = "Year", values_to = "Value")

energy_csv$`Industry sector` <- sub("Total", "", energy_csv$`Industry sector`)

# Format csv 

csv_formatted <- energy_csv %>% 
         mutate("Series" = "Energy intensity level of primary energy",
           "Unit measure" = "Terajoules per million pounds (TJ/£ million)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value")

csv_formatted <- csv_formatted %>%            
select("Year", "Series", "Industry sector", "Unit measure", "Unit multiplier", "Observation status", "Value")

csv_output <- csv_formatted[order(csv_formatted$`Industry sector`), ]





