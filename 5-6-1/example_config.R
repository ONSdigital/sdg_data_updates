# configurations for update 5-6-1

# define years vector to loop through
# covers 2019/20 until present (no 21/22)
# Format and data changes slightly after 18/19, so just automating for 19-20 onwards at the mo
years <- c("19-20", "20-21", "21-22")


# Create an empty list of all the years
filename_list <- vector(mode = "list", length = length(years))

# Loop to create list of all input filenames
# IMPORTANT that all filenames are in this format
for (i in 1:length(years)) {
  filename_list[i] <- paste0("srh-serv-eng-", years[i], "-tab.xlsx")
}


tabname_age <- "Table 7"
#tabname_la <- "Table 17a"  #Had to code this in main update file as it changes between years

# header_row <- 1
header_row_age <- 5 # the row that will be the column headings
header_row_la <- 7

input_folder  <- "Input"
output_folder <- "Output"
