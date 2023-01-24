# date: 04/04/2022
# THIS IS A TEMPLATE. It may be that not everything is relevant for your data.
# This script runs on test data so you can look at what everything does line by line

# Type 2 data is complex - multiple rows/columns containing headers
# There may or may not be metadata above the column headings 

# Most comments can (should) be deleted in your file 

# read in data -----------------------------------------------------------------

smoking_source_data <- get_type1_data(header_row, filename, tabname)

# format data ------------------------------------------------------------------

smoking_data <- extract_data(smoking_source_data, header_row)

smoking_data <- smoking_data %>% select(-ends_with(c("UCL", "LCL"))) 

smoking_data <- smoking_data %>% select(contains(c("Sex", 
                                                   "Country", 
                                                   "Age group", 
                                                   "Current smokers"))) 

smoking_data <- smoking_data %>% select(-"Country code")

smoking_data <- smoking_data %>% 
  pivot_longer(-c("Sex", "Country code", "Country", "Age group"), 
               names_to = "Year", 
               values_to = "Value")

# Need to figure out how to delete all info in cells apart from year

# finalise the csv -------------------------------------------------------------

smoking_data <- smoking_data %>% 
  mutate("Units" = "Percentage",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value") %>%  # make sure to check source data and manually change this if data is provisional etc.
  select("Year", "Sex", "Country", "Age group", "Units", 
         "Unit multiplier", "Observation status", "Value")

