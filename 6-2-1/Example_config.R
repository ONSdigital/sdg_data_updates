# configurations for 6-2-1 data

# There should be three files in the 6-2-1/Input folder. 
  # washdash_facility_type.csv
  # washdash_criteria.csv
  # washdash_service_level.csv


# The following three lines call these files.
filename_facility <- "washdash_facility_type.csv"

filename_safe <- "washdash_criteria.csv"

filename_service <- "washdash_service_level.csv"


# This line calls the tab within each of these files. 
tabname <- "washdash-download"


# This line states the row that the clumn names are given
 header_row <- 1


# Define the names of the input and output folders.
input_folder  <- "Example_Input"
output_folder <- "Example_Output"



