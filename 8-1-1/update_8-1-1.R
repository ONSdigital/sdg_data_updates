# author: Katie Uzzell
# date: 03/05/2023

# Code to automate data update for indicator 8-1-1 (Annual growth rate of real GDP per capita).

# read in data 

gdp_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

gdp_main_data <- extract_data(gdp_source_data, header_row)

# select wanted columns and rows

gdp_main_data <- gdp_main_data %>% 
  select(c("CDID","N3Y6"))

gdp_main_data <- gdp_main_data[gdp_main_data$CDID >= 2000 & gdp_main_data$CDID <= latest_year, ]

gdp_main_data <- gdp_main_data[!grepl("Q", gdp_main_data$CDID),]

# format

gdp_main_data <- gdp_main_data %>% 
  rename("Year" = CDID, "Value" = N3Y6)

csv_formatted <- gdp_main_data %>% 
         mutate("Series" = "Annual growth rate of real GDP per capita",
           "Unit measure" = "Percentage (%)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value")

csv_output <- csv_formatted %>%            
select("Year", "Series", "Unit measure", "Unit multiplier", "Observation status", "Value")






