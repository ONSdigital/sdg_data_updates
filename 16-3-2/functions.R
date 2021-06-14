# Author: Emma Wood
# Date (start): 10/06/2021
# Purpose: Functions for tidying 16.3.2 data.
# Notes: Functions are written in the order they appear in the script. 
#   They are arranged to be read in order: A function higher up the code may call a function lower down the code 
#   (like a newspaper - broad paragraph, follwed by more detailed paragraph)

# I haven't updated SDGupdater::remove_superscripts with this as it is also a special case where there is a superscript to a number
# and that function requires that the character string starts with letters
remove_bracketted_superscripts <- function(variable) {
  bracketted_superscripts <- c("(1)","(2)","(3)","(4)","(5)","(6)","(7)","(8)","(9)")
  
  ifelse(substr(variable, nchar(variable)-2, nchar(variable)) %in% bracketted_superscripts,
         substr(variable, 1, nchar(variable)-3), variable)
}

#---
create_disaggregation_columns <- function(dat) {
  unpivoted <- unpivot_data(dat)
  separated_columns <- separate_columns(unpivoted)
  status_for_each_row <- fill_column_with_type(dat = separated_columns, type = Status)
  completed_status_column <- complete_status_column(separated_columns, entry_for_each_row = status_for_each_row)
  completed_sex_column <- complete_sex_column(completed_status_column)
  year_column_added <- add_year_column(completed_sex_column)
  
  return(year_column_added)
}

unpivot_data <- function(dat){
  dat %>%
    unpivotr::behead("left", sex_age_status) %>%
    unpivotr::behead("up", Date) %>%  
    dplyr::select(sex_age_status, Date, numeric, row) 
}

separate_columns <- function(dat){
  dat %>% 
    dplyr::mutate(Sex = ifelse(grepl('male|Male', sex_age_status) == TRUE, sex_age_status, NA),
                  Age = ifelse(grepl('[0-9]', sex_age_status) == TRUE, sex_age_status, NA),
                  Status = ifelse(is.na(Sex) & is.na(Age), sex_age_status, NA))
}

fill_column_with_type <- function(dat, type){
  first_row_each_type <- get_first_row_for_each_type(dat = dat, type = !!enquo(type))
  type_rows_marked <- join_type_row_numbers_to_data(first_rows = first_row_each_type, all_rows = dat)
  type_for_each_row <- get_type_for_each_row(dat = type_rows_marked, type = !!enquo(type))
  return(type_for_each_row)
}
get_first_row_for_each_type <- function (dat, type) {
  dat %>% 
    arrange(row) %>% 
    group_by(!!enquo(type)) %>% 
    filter(row_number() == 1) %>% 
    distinct(!!enquo(type), row) 
}
join_type_row_numbers_to_data <- function(first_rows, all_rows){
  data.frame(row = c(min(all_rows$row):max(all_rows$row))) %>% 
    left_join(first_rows, by = "row") 
}
get_type_for_each_row <- function(dat, type){
    tidyr::fill(dat, !!enquo(type))
}

complete_status_column <- function(dat, entry_for_each_row){
  dat %>% 
    select(-Status) %>% 
    left_join(entry_for_each_row, by = "row") 
}

complete_sex_column <- function(dat) {
  sex <- get_sex(dat)
  dat %>% 
    mutate(Sex = sex)
}
get_sex <- function(dat) {
  sex_entries <- unique(dat$Sex)
  sex_entries[!is.na(sex_entries)]
}

add_year_column <- function(dat) {
  
  # if the Date has a superscript, it will be read in the format DD-MMM(letters)-YY
  # otherwise it will be YYY-MM-DD, so we need to identify which is which and treat accordingly
  dat %>% 
    mutate(Year = ifelse(substr(Date, 5, 5) %in% letters,
                         paste0("20", substr(Date, 8,9), " see note in original data"),
                         substr(Date, 1, 4)))
}

#----
