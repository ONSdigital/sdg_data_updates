# Make sure that all number columns in the beachwatch data are formatted as numbers 
# WITHOUT the thousands separator (',') 

filename_main_data <- "Beachwatch_GBBC_1994-2021.csv"
filename_sources <- "beachwatch_sources_2021_1.0.csv"
cover_sheet_filename <- "cover_sheet.xlsx" 

output_folder <- "Example_Output"
input_folder <- "Example_Input"

# ------------------------------------------------------------------------------
# You probably won't need to edit below this line
# ------------------------------------------------------------------------------

plastic_keywords <- c("plastic_polystyrene", "rubber", "sanitary", "medical")
# if further surveys are identified that need to be combined they can just be 
# added to this list as they will be summed based on date and location.
surveys_to_sum <- c(52625, 53140)
