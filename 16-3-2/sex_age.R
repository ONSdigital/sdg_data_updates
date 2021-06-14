# Author: Emma Wood
# Date (start): 10/06/2021
# Purpose: To create csv data for age and sex 16.3.2.
# Requirements: Functions specific to this indicator are called from functions.R

age_sex_data <- dplyr::filter(source_data, sheet == age_sex_tabname)

data_without_superscripts <- age_sex_data %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character))) %>% 
  dplyr::mutate(character = remove_bracketted_superscripts(character)) %>% 
  mutate(across(where(is.character), stringr::str_trim))

first_set <- filter(data_without_superscripts, row %in% first_date_row_age_sex:(second_date_row_age_sex - 1))
first_set_correct_columns <- create_disaggregation_columns(first_set)

second_set <- filter(data_without_superscripts, row %in% second_date_row_age_sex:(third_date_row_age_sex - 1))
second_set_correct_columns <- create_disaggregation_columns(second_set)

third_set <- filter(data_without_superscripts, row >= third_date_row_age_sex)
third_set_correct_columns <- create_disaggregation_columns(third_set)


all_data <- bind_rows(first_set_correct_columns,
                      second_set_correct_columns,
                      third_set_correct_columns) %>% 
  mutate(Status = ifelse(is.na(Status), "all_prisoners", Status)) %>%
  # from 2010 reporting is quarterly (hidden columns in the source data). we only use the first quarter
  filter(substr(Date, 7, 7) == month_numeric | substr(Date, 4, 6) == month_character) %>% 
  filter(!is.na(numeric)) %>% 
  select(-c(row, sex_age_status, Date))

data_for_calculations <- all_data %>% 
  tidyr::pivot_wider(names_from = Status,
                     values_from = numeric)

proportions_calculated <- data_for_calculations %>% 
  mutate(Value = (Remand / all_prisoners) * 100) %>% 
  mutate(Value = ifelse(is.na(Value) & Remand == 0, 0, Value))

csv_sex_age <- proportions_calculated %>% 
  mutate(Sex = case_when(
           Sex == "Males and females" | Sex == "Males and Females" | Sex == "males and females" ~ "",
           Sex == "Females" | Sex == "females"  ~  "Female",
           Sex == "Males" | Sex == "males" ~ "Male",
           TRUE ~ as.character(Sex)),
         Age = gsub("-", " to ", Age),
         Age = ifelse(is.na(Age), "", Age),
         Nationality = "",
         `Unit measure` = "Percentage (%)",
         `Unit multiplier` =  "Units",
         `Observation status` = "Undefined") %>% 
  select(Year, Sex, Age, Nationality, `Unit measure`, `Unit multiplier`, `Observation status`, Value)

rm(data_without_superscripts)

