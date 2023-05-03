# configurations for type 1 data

filename <- "gdpolowlevelaggregates2022q4.xlsx"
# # If you are using csv data make sure numbers are formatted as numbers in Excel 
# # and DO NOT include the thousands separator
# # tabname will not be needed if you are using csv data
# filename <- "type_1_metadata_included.csv"
# filename <- "type_1_no_metadata.csv"

# tabname <- "no_metadata"
tabname <- "2a"

selected_years <- c(1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, 
                    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
                    2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 
                    2020, 2021, 2022)

latest_year <- 2022

header_row <- 6

input_folder  <- "Example_Input"
output_folder <- "Example_Output"
