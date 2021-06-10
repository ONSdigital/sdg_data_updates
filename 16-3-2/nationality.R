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
  unpivotr::behead("left", nationality_status_detail) %>%
  unpivotr::behead("up", Date) %>%  
  dplyr::select(nationality_status_detail, Date, numeric, row) 

potential_nationalities <- c("Total", "British nationals", "Foreign nationals", "Nationality not recorded")

tidied_data <- unpivoted_data %>% 
  filter(!is.na(numeric)) %>% 
  mutate(Nationality = ifelse(nationality_status_detail %in% potential_nationalities|
                                grepl("ation", nationality_status_detail) == TRUE, # this line added in case capitalization is different or another nationality containing the word nation is added
                              nationality_status_detail, NA),
         Status = ) %>% 
  # there is a typo in the data - it says British national where it should say Remand - figure out how to fix this (something to do with order?) or change it in the file? The latter may be a better use of my time

# 
# all_data <- bind_rows(first_set_correct_columns,
#                       second_set_correct_columns,
#                       third_set_correct_columns) %>% 
#   mutate(Status = ifelse(is.na(Status), "all_prisoners", Status)) %>%
#   # from 2010 reporting is quarterly (hidden columns in the source data). we only use the first quarter
#   filter(substr(Date, 7, 7) == 6 | substr(Date, 4, 6) == "Jun") %>% 
#   filter(!is.na(numeric)) %>% 
#   select(-c(row, sex_age_status, Date))
# 
# data_for_calculations <- all_data %>% 
#   tidyr::pivot_wider(names_from = Status,
#                      values_from = numeric)
# 
# proportions_calculated <- data_for_calculations %>% 
#   mutate(Value = (Remand / all_prisoners) * 100)
# 
# csv_sex_age <- proportions_calculated %>% 
#   mutate(Sex = ifelse(Sex == "Males and females" | Sex == "Males and Females" | Sex == "males and females",
#                       "", Sex),
#          Age = gsub("-", " to ", Age),
#          Age = ifelse(is.na(Age), "", Age),
#          Nationality = "",
#          `Unit measure` = "Percentage (%)",
#          `Unit multiplier` =  "Units",
#          `Observation status` = "Undefined") %>% 
#   select(Year, Sex, Age, Nationality, `Unit measure`, `Unit multiplier`, `Observation status`, Value)
# 
# 
# 
