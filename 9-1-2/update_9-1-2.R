# author: Katie Uzzell
# date: 02/03/2023

# Code to automate data update for indicator 9-1-2 (Air passenger and air freight volumes).

freight_source_data <- get_type1_data(header_row, filename, freight_tabname)

passenger_source_data <- get_type1_data(header_row, filename, passenger_tabname)

freight_main_data <- extract_data(freight_source_data, header_row) %>% 
  rename("Flight category" = Service) 

freight_main_data <- freight_main_data[freight_main_data$`Flight category` %in% 
                                          c("International Total",
                                            "Domestic Total",
                                            "All Traffic"),]

freight_main_data[freight_main_data == "International Total"] <- "International"
freight_main_data[freight_main_data == "Domestic Total"] <- "Domestic"
freight_main_data[freight_main_data == "All Traffic"] <- ""

freight_csv <- freight_main_data %>% 
  pivot_longer(-c("Flight category"), names_to = "Year", values_to = "Value")

freight_csv <- freight_csv %>% 
  mutate("Units" = "Tonnes",
         "Unit multiplier" =  "Thousands",
         "Observation status" = "Normal value", # make sure to check source data and manually change this if data is provisional etc.
         "Series" = "Freight (thousand tonnes)") %>%
  select("Year", "Series", "Flight category", "Observation status", 
         "Unit multiplier", "Units", "Value")

passenger_main_data <- extract_data(passenger_source_data, header_row) %>% 
  rename("Flight category" = Service)

passenger_main_data <- passenger_main_data[passenger_main_data$`Flight category` %in% 
                                             c("International Total",
                                               "Domestic Total",
                                               "All Traffic"),]

passenger_main_data[passenger_main_data == "International Total"] <- "International"
passenger_main_data[passenger_main_data == "Domestic Total"] <- "Domestic"
passenger_main_data[passenger_main_data == "All Traffic"] <- ""

passenger_csv <- passenger_main_data %>% 
  pivot_longer(-c("Flight category"), names_to = "Year", values_to = "Value")

passenger_csv <- passenger_csv %>% 
  mutate("Units" = "Number",
         "Unit multiplier" =  "Thousands",
         "Observation status" = "Normal value", # make sure to check source data and manually change this if data is provisional etc.
         "Series" = "Terminal passengers (thousands)") %>%
  select("Year", "Series", "Flight category", "Observation status", 
         "Unit multiplier", "Units", "Value")

csv_output <-  bind_rows(freight_csv, passenger_csv)






