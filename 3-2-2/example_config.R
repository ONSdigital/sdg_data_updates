input_folder <- "Example data"
output_folder <- "Example output"

filename <- "example_data_3-2-2.xlsx"


england_and_wales_timeseries_tab_name <- "NA" #"Table 1" or "NA" if running tables for years earlier than 2019
first_header_row_england_and_wales <- 4 # just leave as is if running tables for years earlier than 2019

country_of_occurrence_by_sex_tab_name <- "Table 2"
first_header_row_country_by_sex <- 4

area_of_residence_tab_name <- "Table 3"
first_header_row_area_of_residence <- 4 #4

birthweight_by_mum_age_tab_name <- "Table 10" #"Table 14"
first_header_row_birthweight_by_mum_age <- 4

country_of_birth_tab_name <- "Table 11" #"Table 15"
first_header_row_country_of_birth <- 4

#-------------------------------------------------------------------------------
# the following are unlikely to need changing:
decimal_places <- 1
expected_number_of_rows_in_output <- 71 # Currently 129 for real data

# country of birth is different before 2010 so want to turn it off for these
# (still include a valid table name otherwise it won't work)
include_country_of_birth <- TRUE # TRUE or FALSE
