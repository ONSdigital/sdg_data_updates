# author: Katie Uzzell
# date: 03/05/2023

# Code to automate data update for indicator 9-b-1 (Proportion of medium and high-tech industry value added in total value added)

# read in data 

gdp_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

gdp_main_data <- extract_data(gdp_source_data, header_row)

# rename column 1

colnames(gdp_main_data) [1] <- "Year"

# select unwanted columns

gdp_main_data <- select(gdp_main_data, c("Year","KL8V", "KL5Q", "KL5X", "KL68", 
                                         "KL6A", "KL6B", "KL6C", "KL6D", "KL6G", "KL6H"))

gdp_main_data <- gdp_main_data[!grepl("Q", gdp_main_data$Year),]



gdp_main_data <- gdp_main_data %>% 
  mutate(Total = select(., "KL5Q", "KL5X", "KL68", "KL6A", "KL6B", "KL6C", 
                        "KL6D", "KL6G", "KL6H") %>% rowSums(na.rm = TRUE))

           

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





