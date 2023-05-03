# configurations for type 1 data

filename <- "ukea.xlsx"
# # If you are using csv data make sure numbers are formatted as numbers in Excel 
# # and DO NOT include the thousands separator
# # tabname will not be needed if you are using csv data
# filename <- "type_1_metadata_included.csv"
# filename <- "type_1_no_metadata.csv"

# tabname <- "no_metadata"
tabname <- "data"

# header_row <- 1
header_row <- 2

selected_years <- c(2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
                    2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
                    2020, 2021, 2022)

latest_year <- 2022

input_folder  <- "Example_Input"
output_folder <- "Example_Output"
