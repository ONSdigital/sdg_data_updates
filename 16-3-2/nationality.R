# Author: Emma Wood
# Date (start): 10/06/2021
# Purpose: To create csv data for nationality 16.3.2.

nationality_data <- dplyr::filter(source_data, sheet == nationality_tabname)

# # info cells are the cells above the column headings
# info_cells <- SDGupdater::get_info_cells(nationality_data, date_row_nationality)
# start_and_end_years <- SDGupdater::unique_to_string(info_cells$Year)

data_without_superscripts <- nationality_data %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character))) %>% 
  dplyr::mutate(character = remove_bracketted_superscripts(character)) %>% 
  mutate(across(where(is.character), stringr::str_trim))

main_data <- filter(data_without_superscripts, row >= date_row_nationality)

unpivoted_data <- main_data %>% 
  unpivotr::behead("left", nationality_status) %>%
  unpivotr::behead("up", Date) %>%  
  dplyr::select(nationality_status, Date, numeric, row) 

potential_nationalities <- c("Total", "British nationals", "Foreign nationals", "Nationality not recorded")

tidied_data <- unpivoted_data %>% 
  filter(!is.na(numeric)) %>% 
  mutate(Nationality = ifelse(nationality_status %in% potential_nationalities|
                                grepl("ation", nationality_status) == TRUE, # this line added in case capitalization is different or another nationality containing the word nation is added
                              nationality_status, NA),
         Status = ifelse(nationality_status %not_in% potential_nationalities &
                           grepl("ation", nationality_status) == FALSE,
                         nationality_status, NA)) 

nationality_for_each_row <- fill_column_with_type(dat = tidied_data,
                                                  type = Nationality)

completed_nationality_column <- tidied_data %>% 
  select(-Nationality) %>% 
  left_join(nationality_for_each_row, by = "row")

data_with_year <- add_year_column(completed_nationality_column)
 
all_data <- data_with_year %>%
  mutate(Status = ifelse(is.na(Status), "all_prisoners", Status)) %>%
  # from 2010 reporting is quarterly (hidden columns in the source data). we only use the first quarter
  filter(substr(Date, 7, 7) == month_numeric | substr(Date, 4, 6) == month_character) %>% 
  filter(!is.na(numeric)) %>%
  select(-c(row, nationality_status, Date))
 
data_for_calculations <- all_data %>%
  tidyr::pivot_wider(names_from = Status,
                     values_from = numeric)

proportions_calculated <- data_for_calculations %>%
  mutate(Value = (Remand / all_prisoners) * 100) %>% 
  mutate(Value = ifelse(is.na(Value) & Remand == 0, 0, Value))

csv_nationality <- proportions_calculated %>%
  mutate(Nationality = ifelse(Nationality == "Total",
                      "", Nationality),
         Sex = "",
         Age = "",
         `Unit measure` = "Percentage (%)",
         `Unit multiplier` =  "Units",
         `Observation status` = "Undefined") %>%
  select(Year, Sex, Age, Nationality, `Unit measure`, `Unit multiplier`, `Observation status`, Value)



