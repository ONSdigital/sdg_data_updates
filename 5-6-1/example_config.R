# configurations for update 5-6-1

# define years vector to loop through
# covers 2019/20 until present (now 21/22)
# Format and data changes slightly after 18/19, so just automating for 19-20 onwards at the mo

#' Need 2 lists of years because the filename format is slightly different
#' Is set up here so that you only put in the years you want to read in in the
#' '2021/22' format (years variable), then the program will sort out the filename format for you 
years <- c("2019/20", "2020/21", "2021/22")
# Create another empty list for years in filename format
years_filenames <- vector(mode = "list", length = length(years))

for (x in 1:length(years)) {
  # Get rid of the first two digits of the year
  years_filenames[x] <- substring(years[x], 3)
  years_filenames[x] <- gsub("/", "-", as.character(years_filenames[x]))
}

# Create an empty list of all the years
filename_list <- vector(mode = "list", length = length(years_filenames))

# Loop to create list of all input filenames
# IMPORTANT that all filenames are in this format in the folder
for (i in 1:length(years_filenames)) {
  filename_list[i] <- paste0("srh-serv-eng-", years_filenames[i], "-tab.xlsx")
}


tabname_age <- "Table 7"
#tabname_la <- "Table 17a"  #Had to code this in main update file as it changes between years

# header_row <- 1
header_row_age <- 5 # the row that will be the column headings
header_row_la <- 7

input_folder  <- "Input"
output_folder <- "Output"
