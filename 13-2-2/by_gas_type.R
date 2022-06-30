# Author: Emma Wood
# Contact: emma.wood@ons.gov.uk
# Date (start): 18/02/2021
# Purpose: To create csv-format headline figures for 13-2-2
# Requirements: This script is called by compile_tables.R, which is called by main.R

# read in data -----------------------------------------------------------------

source_data <- xlsx_cells(paste0(input_folder, "/", filename), sheets = headline_tab_name) 

info_cells <-  SDGupdater::get_info_cells(source_data, 
                                          first_header_row, 
                                          "xlsx_cells")

# get the info from above the headers-------------------------------------------
years <- unique_to_string(info_cells$Year)
latest_year <- max(as.numeric(strsplit(years, ",")[[1]]))
earliest_year <- min(as.numeric(strsplit(years, ",")[[1]]))

country <- unique_to_string(info_cells$Country)

# remove info cells and clean character column ---------------------------------
clean_cells <- source_data %>%
  SDGupdater::remove_blanks_and_info_cells(first_header_row) %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  dplyr::mutate(character = SDGupdater::remove_superscripts(character))

# put data into a more standard format -----------------------------------------
beheaded <- clean_cells %>%
  behead("up", Year) %>%
  behead("left", Gas) %>% 
  select(Year, Gas, numeric)

# finalise the csv -------------------------------------------------------------
csv_formatted  <- beheaded %>% 
  janitor::remove_empty(c("rows", "cols")) %>% 
  rename(Value = numeric) %>% 
  arrange(Year, Gas) %>% 
  mutate(Gas = ifelse(grepl("otal", Gas), "", Gas),
         `Observation status` = ifelse(is.na(Value), "Missing value", "Normal value"),
         `Unit multiplier` = "Units",
         Units = "Million tonnes carbon dioxide equivalent (MtCO2e)") %>% 
  # we changed everything to lowercase at the top of the script, 
  # so now we need to change them back to the correct case
  select(Year, Gas, 
         `Observation status`,
         `Unit multiplier`, Units,
         Value)

rm(info_cells, clean_cells, source_data, beheaded, units, years)
