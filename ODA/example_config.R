# Configurations for all ODA indicators that use the data underlying SID source.
# If you only want to run a subset of these you can comment out (#) the ones
# you don't want to run

indicators <- c(
  "1-a-1", # net oda
  "2-a-2", # net oda
  "3-b-2", # net oda
  "4-b-1", # amounts extended
  "6-a-1", # amounts extended
  "7-a-1", # net ODA
  "8-a-1", # amounts extended
  "9-a-1", # net ODA
  "17-9-1", # net ODA
  "17-19-1" # net ODA
)

# ODA indicators without an automation yet as different data source is used: 10-b-1, 17-2-1, 17-3-1, 15-a-1, 15-b-1
#-------------------------------------------------------------------------------

input_folder <- "Example_Input"
output_folder <- "Example_Output"

# filenames of the ODA data (data underlying SID). 
filename_newdat <- "dataunderSID-Final2020_example.csv"
filename_2017 <- "data-underlying-sid-2017_example.csv"

deflators_filename <- "Deflators-base-2020_example.xlsx"
exchange_filename <- "Exchange-rates_example.xlsx"

#-------------------------------------------------------------------------------
# configs below probably won't need to be edited

# 1-a-1 uses GNI. This is accessed by API from OECD
# the link is given in compile tables, where the end date is also generated.
# building this link requires the first year of data required:
gni_start_year <- "2009" 

# Codes used for individual indicators- I don't expect these will change, but
# they are here just in case.
broad_sector_code_2a2 <- 311
broad_sector_code_3b2 <- 122
broad_sector_code_6a1 <- 140
broad_sector_code_8a1 <- 331

crs_code_3b2 <- 12182 
crs_code_6a1 <-  31140
crs_codes_7a1 <- c(23210, 23220, 23230, 23240, 23250, 23260, 23270)
crs_code_17191 <- 16062

type_of_aid_code_4b1 <- "E01"

sid_sector_9a1 <- "economic infrastructure" # capitalisation not important