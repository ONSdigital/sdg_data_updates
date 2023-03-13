# configurations for 3-2-1 data

filename <- "EXAMPLE_cim2020deathcohortworkbook.xlsx"

# tabname
tabname_EW <- "1"
tabname_UK <- "2"

# row where the column headers are in each sheet
header_row_EW <- 6
header_row_UK <- 7

input_folder  <- "Example_Input"
output_folder <- "Example_Output"

# just in case the geocode changes
england_wales_geocode <- "K04000001"

# in 2020, figures for Northern Ireland (births & deaths) are for different populations
# so we need to make sure NI values are blank in united_kingdom.R. Here we set a string
# that will only come up in Northern Ireland regardless of format. I've left this in
# the config so that if this is no longer needed in future years you can set this 
# as a string that will never come up (e.g. "licorice") instead of rooting around 
# in the update code - not a good idea to set as blank because that comes up a lot
NI_string = "orthern"
