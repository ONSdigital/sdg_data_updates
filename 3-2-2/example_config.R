input_folder <- "Example input"
output_folder <- "Example output"

filename <- "example_data_new_3-2-2.xlsx"


england_and_wales_timeseries_tab_name <- "Table_1" # "Table 1" or "NA" if running tables for years earlier than 2019
first_header_row_england_and_wales <- 6 # 4 for older data # just leave as is if running tables for years earlier than 2019

country_of_occurrence_by_sex_tab_name <- "Table_2" # "Table 2" for older data
first_header_row_country_by_sex <- 7 # 4 for older data

area_of_residence_tab_name <- "Table_3" # "Table 3" for older data
first_header_row_area_of_residence <- 7 # 4 for older data

birthweight_by_mum_age_tab_name <- "Table_10" # "Table 10" for older data
first_header_row_birthweight_by_mum_age <- 7 # 4 for older data

country_of_birth_tab_name <- "Table_11" # "Table 11" for older data
first_header_row_country_of_birth <- 7 # 4 for older data

ethnicity_tab_name <- "Table_18" # "NA" for older data
first_header_row_ethnicity <- 7

#-------------------------------------------------------------------------------
# the following are unlikely to need changing:
decimal_places <- 1

# country of birth is different before 2010 so want to turn it off for these
# (still include a valid table name otherwise it won't work)
include_country_of_birth <- TRUE # TRUE or FALSE

# The data layout changed significantly in the 2022 publication (2020 data)
# so if running on data older than this, change pre_2020_data to TRUE as it 
# will use different scripts
pre_2020_data <- FALSE # TRUE for older data
