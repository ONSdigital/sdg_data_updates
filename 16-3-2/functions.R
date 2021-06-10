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

create_disaggregation_columns <- function(dat) {
  unpivoted <- unpivot_data(dat)
  separated_columns <- separate_columns(unpivoted)
  first_status_row <- get_first_row_for_each_status(separated_columns)
  status_for_each_row <- get_status_for_each_row(first_status_row)
  completed_status_column <- complete_status_column(separated_columns)
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
get_first_row_for_each_status <- function (dat) {
  dat %>% 
    arrange(row) %>% 
    group_by(Status) %>% 
    filter(row_number() == 1) %>% 
    distinct(Status, row) 
}
get_status_for_each_row <- function(dat){
  data.frame(row = c(min(separated_columns$row):max(separated_columns$row))) %>% 
    left_join(dat, by = "row") %>% 
    tidyr::fill(Status)
  
}
complete_status_column <- function(dat){
  dat %>% 
    select(-Status) %>% 
    left_join(status_for_each_row, by = "row") 
}
complete_sex_column <- function(dat) {
  sex <- get_sex(dat)
  dat %>% 
    mutate(Sex = sex)
}
add_year_column <- function(dat) {
  
  # if the Date has a superscript, it will be read in the format DD-MMM(letters)-YY
  # otherwise it will be YYY-MM-DD, so we need to identify which is which and treat accordingly
  dat %>% 
    mutate(Year = ifelse(substr(Date, 5, 5) %in% letters,
                         paste0("20", substr(Date, 8,9), " see note in original data"),
                         substr(Date, 1, 4)))
}

get_sex <- function(dat) {
  sex_entries <- unique(dat$Sex)
  sex_entries[!is.na(sex_entries)]
}