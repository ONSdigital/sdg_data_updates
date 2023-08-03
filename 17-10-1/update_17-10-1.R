# author: Katie Uzzell
# date: 12/01/2023

# Code to automate data update for indicator 17-10-1 (Energy intensity measured in terms of primary energy and GDP)

# read in data 

Jan_data <- get_type1_data(header_row, Jan_data, Jan_tabname)
Feb_data <- get_type1_data(header_row, Feb_data, Feb_tabname)
Mar_data <- get_type1_data(header_row, Mar_data, Mar_tabname)
Apr_data <- get_type1_data(header_row, Apr_data, Apr_tabname)
May_data <- get_type1_data(header_row, May_data, May_tabname)
Jun_data <- get_type1_data(header_row, Jun_data, Jun_tabname)
Jul_data <- get_type1_data(header_row, Jul_data, Jul_tabname)
Aug_data <- get_type1_data(header_row, Aug_data, Aug_tabname)
Sep_data <- get_type1_data(header_row, Sep_data, Sep_tabname)
Oct_data <- get_type1_data(header_row, Oct_data, Oct_tabname)
Nov_data <- get_type1_data(header_row, Nov_data, Nov_tabname)
Dec_data <- get_type1_data(header_row, Dec_data, Dec_tabname)

#joining datasets together 

all_data <- full_join(Jan_data, Feb_data, by = c("Date", "Country"))


# remove cells above column names

energy_main_data <- extract_data(energy_source_data, header_row)

# rename column 3

colnames(energy_main_data) [1] <- "Sector code"
colnames(energy_main_data) [2] <- "Section code"
colnames(energy_main_data) [3] <- "Industry sector"

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

# The below line may or may not be necessary in future releases
# csv_formatted$Year <- gsub("2020 2", "2020", csv_formatted$Year)

csv_formatted <- csv_formatted %>%            
select("Year", "Series", "Industry sector", "Unit measure", "Unit multiplier", "Observation status", "Value")

csv_output <- csv_formatted[order(csv_formatted$`Industry sector`), ]





