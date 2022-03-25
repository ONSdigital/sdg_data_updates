# EMMA - EDIT THIS FUNCTION IN A NEW BRANCH
# change the warning given when year/country isn't present
# it currently says 1: Problem while computing `Year = get_all_years(character)`.
# i input is of class logical but should be a list 
# author: Emma Wood
# date: 24/03/2022
# THIS IS A TEMPLATE NOT A WORKING SCRIPT

# Type 1 data is simple - one row of column headings and no row names
# There may or may not be metadata above the column headings - this code allows for both scenarios

# comments can be deleted in your file 

setwd("template") # this line is to run the template only - do not copy

# read in data -----------------------------------------------------------------

if (header_row == 1) {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = tabname, 
                                     colNames = TRUE)  
} else {
  source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                     sheet = tabname, 
                                     colNames = FALSE, skipEmptyRows = FALSE) 
}

# clean the columns that contain strings ---------------------------------------

clean_data <- source_data %>% 
  # change factors to characters as each level of a factor is given a number and so doesn't behave like a string
  mutate(across(where(is.factor), as.character)) %>% 
  # change all strings to lowercase so that if the case is different in the future the code will still work
  mutate(across(where(is.character), tolower)) %>% 
  # remove all trailing white space and change multiple spaces to single spaces within the string
  mutate(across(where(is.character), str_squish)) %>% 
  # the following lines removes superscripts
  # DO NOT USE remove_superscripts() if there are cells containing words that end 
  #   in a number that you want to keep:
  #   It won't usually remove a number from the end of an alphanumeric code, 
  #   but will do so if the ONLY number is at the end
  mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))


# separate the data from the above-table metadata ------------------------------

if (header_row > 1) {
  data_no_headers <- clean_data[(header_row + 1):nrow(clean_data), ]
  
  # only use the following if you need the country and year info contained above the headers 
  # (it may be useful to put the details the are output in the QA file)
  metadata <- get_info_cells(clean_data, header_row, "xlsx")
  year <- unique_to_string(metadata$Year) # only if year is expected in the info above the header
  country <- unique_to_string(metadata$Country) # only if country is expected in the info above the header
}

# clean the column names -------------------------------------------------------

if (header_row > 1){
  main_data <- data_no_headers
  names(main_data) <- clean_data[header_row, ]
} else {
  main_data <- clean_data
}

# remove superscripts from column names
# DO NOT use if there are column names containing words that end 
#   in a number: It won't usually remove a number from the end of an alphanumeric code, 
#   but will do so if the ONLY number is at the end)
names(main_data) <- SDGupdater::remove_superscripts(names(main_data)) 

# clean up the column names (snake case, lowercase, no trailing dots etc.)
main_data <- clean_names(main_data)

# remove footnotes -------------------------------------------------------------
# this assumes that:
# footnotes might only be in the number of columns stated in check_columns.
# if the data are likely to have non-footnote data in the first column(s) but NAs
# in all other columns DO NOT use this function as it will likely remove more 
# than just footnotes

remove_footnotes <- function(data, check_columns) {
  
  column_count <- ncol(data)
  footnote_na_count <- (column_count - check_columns):column_count
  
  data_na_count <-  data %>% 
    mutate(na_count = rowSums(is.na(data)))
  
  for (i in nrow(data_na_count):1) {
    
    last_row <- data_na_count[i, ]
    
    na_count_end_columns <- sum(is.na(last_row[, (check_columns + 1):column_count]))
    end_columns_all_NA <- na_count_end_columns  == (column_count - check_columns)
    
    if (last_row$na_count %in% footnote_na_count & end_columns_all_NA) {
      
      data_na_count <- data_na_count[-i, ]
      
    } else {
      
      break
    }
    
  }
  return(data_na_count)
}
# count the number of NAs in the bottom row of data
# if all columns are NA remove bottom row
# if the first column is not NA, and all other columns are NA remove the bottom row
# if the 1st and 2nd columns are not NA but the others are remove the bottom row
# move up a row and continur until this is false

remove_footnotes(main_data, 2)

# make column names consistent across years ------------------------------------

# If you know a column name may change year to year you can rename these columns
# so that the code will always work regardless of the name.
# You can use the rename_column function to rename them based on patterns that 
# are always present in the column name. See below for some examples of usage.
#
# You can then use the new name to refer to the columns through the 
# rest of the code.

# If there aren't too many columns that you are going to use you could do this 
# step for all columns but be careful you don't introduce errors!

renamed_main <- main_data %>% 
  rename_column(primary = "year", new_name = "year") %>% 
  rename_column(primary = "sex", new_name = "sex") %>% 
  rename_column(primary = c("sample", "size"), alternate = "count", 
                new_name = "sample_size") %>% 
  rename_column(primary = "series", not_pattern = "a|b|c|other",
                new_name = "d")
  

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Join dataframes, do relevant calculations etc

# some useful dplyr functions:
# left_join(), right_join, 
# add_row(), filter(), select(), group_by(), summarise()
# pivot_longer(), pivot_wider()

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# finalise csv -----------------------------------------------------------------

# add extra columns for SDMX, rename levels of disaggregations, 
# put columns in correct order etc 

# order of disaggregations depend on order they appear. In some cases this won't 
# be alphanumeric order, so specify the order here and arrange by this fake column 
# instead of the real one
age_order <- data.frame(Age = c("Under 15", "16 to 40", "41 to 65", "Over 65"),
                        Age_order = c(1:4))

csv_formatted <- indicator_data %>% 
  # we changed everything to lowercase at the top of the script, 
  # so now we need to change them back to the correct case
  mutate(Country = str_to_title(Country)) %>% 
  # we also changed column names to lowercase, so we need to change them back again too
  # note that column names are changed with rename(), 
  # while contents of columns are changed with mutate()
  rename(Year = year) %>% 
  # rename levels of disaggregations, e.g total/UK will nearly always be replaced 
  # with a blank. Use case_when() if there are lots of options, or ifelse if there is just one
  mutate(Age = 
           case_when(
             Age == "<15" ~ "Under 15",
             Age == ">65" ~ "Over 65",
             # this last line says 'for all other cases, keep Age the way it is
             TRUE ~ as.character(Age)),
         Country = ifelse(Country == "UK", "", Country)) %>% 
  # Remove any rows where the value is NA
  filter(!is.na(Value)) %>% 
  # order of disaggregations depend on order they appear, so sort these now
  left_join(age_order, by = "Age") %>% 
  arrange(Year, Country, Age_order) %>% 
  # Add extra rows required for SDMX
  mutate(`Observation status` = "Undefined",
         `Unit multiplier` = "Units",
         `Unit measure` = "percentage (%)") %>% 
  # Put columns in the order we want them.
  # this also gets rid of the column Age_order which has served its purpose and is no longer needed
  select(Year, Country, Age, 
         `Observation status`, `Unit measure`, `Unit multiplier`,
         Value)





