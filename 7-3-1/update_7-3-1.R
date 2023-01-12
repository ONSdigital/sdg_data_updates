# author: Katie Uzzell
# date: 12/01/2023

# Code to automate data update for indicator 7-3-1 (Energy intensity measured in terms of primary energy and GDP)

# read in data 

energy_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

energy_main_data <- extract_data(seizures_source_data, header_row)

# remove superscripts from column names

# names(energy_main_data) <- SDGupdater::remove_superscripts(names(energy_main_data)) 

# format into csv and remove NAs

#seizures_main_data_totals <- seizures_main_data_totals %>%
#  pivot_longer(-c("Year"), names_to = "Import type", values_to = "Value")


# Format csv 

csv_formatted <- XXXXXXXX %>% 
         mutate("Series" = "Energy intensity level of primary energy",
           "Unit measure" = "Terajoules per million pounds (TJ/£ million)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value")

csv_formatted <- csv_formatted %>%            
select("Year", "Series", "Industry sector", "Unit measure", "Unit multiplier", "Observation status", "Value")

# csv_formatted <- csv_formatted[order(csv_formatted$"Import type"),]

# <- csv_formatted %>% 
#  mutate(Value = ifelse(is.na(Value), "", Value))
