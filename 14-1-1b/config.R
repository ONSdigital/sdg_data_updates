# Make sure that all number columns in the beachwatch data are formatted as numbers 
# WITHOUT the thousands separator (',') - you will get a warning along the 
# lines of Problem while computing `total_volunteer_hours = as.numeric(total_volunteer_hours)`.
# i NAs introduced by coercion 

filepath_main_data <- "D:/coding_repos/sdg_data_creation/14-1-1b/Input/Beachwatch_GBBC_1994-2021.csv"
filepath_sources <- "D:/coding_repos/sdg_data_creation/14-1-1b/Input/beachwatch_sources_2021_1.0.csv"
cover_sheet_filename <- "cover_sheet.xlsx" 

output_folder <- "Output"
input_folder <- "Input"

# ------------------------------------------------------------------------------
# You probably won't need to edit below this line
# ------------------------------------------------------------------------------

plastic_keywords <- c("plastic_polystyrene", "rubber", "sanitary", "medical")
# if further surveys are identifies, that need to be combined they can just be 
# added to this list
surveys_to_sum <- c(52625, 53140)
