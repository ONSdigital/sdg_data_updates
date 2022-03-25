# EMMA - EDIT THIS FUNCTION IN A NEW BRANCH
# change the warning given when year/country isn't present
# it currently says 1: Problem while computing `Year = get_all_years(character)`.
# i input is of class logical but should be a list 
get_info_cells <- function (dat, first_header_row, type="xlsx_cells") {
  
  
  if(type == "xlsx_cells") {
    
    clean_data <- dat %>% 
      filter(row %in% 1:(first_header_row - 1)) %>% 
      distinct(character) %>% filter(!is.na(character)) %>% 
      mutate(character = trimws(character, which = "both")) 
    
  } else { 
    
    above_headers <- dat[1:(first_header_row - 1), ]
    clean_data <- data.frame(character = c(t(above_headers)))
    
  }
  
  output <- clean_data %>% 
    mutate(Year = get_all_years(character)) %>% 
    mutate(Country = get_all_country_names(character))
  number_of_country_NAs <- sum(is.na(output$Country))
  number_of_year_NAs <- sum(is.na(output$Year))
  if (number_of_country_NAs == nrow(output)) {
    warning(paste("No countries were identified in the header section of", 
                  substitute(dat)))
  }
  if (number_of_year_NAs == nrow(output)) {
    warning(paste("No years were identified in the header section of", 
                  substitute(dat)))
  }
  return(output)
}

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

# make column names consistent across years ------------------------------------

# If the source has a history of slight column name changes, you can use the
# rename_column function to rename them based on patterns that are always present
# in the column name. You can then use the new name to refer to it through the 
# rest of the code.




# CONTINUE FROM HERE ###########################################################



#-------------------------------------------------------------------------------
# make column names consistent across years-------------------------------------

# If you know a column name will change year to year you can rename these columns
# so that the code will always work regardless of the name.
# First identify the location of the column that needs to be renamed. You may be
# able to do this based on 1) part of the column name e.g. geospatial data may have
# column names like CTRY20CD in 2020 which become CTRY21CD in 2021. Alternatively
# you may be able to 2) identify a column based on it's contents. e.g the year 
# column could be identified as having a 4 digit number between 1950 and the current
# year (which you could extract from sys.Date()) in every filled cell. (make sure
# this is the only possible column that would fulfill the criteria)



#----
# 2) identify column based on column contents, in this example, identify year
# based on the criteria that all cells are a number between 1950 and the current year
source_data <- data.frame("date" = rep(c(2010:2014), 2),
                          "age" = c(rep("20 to 24", 5,),
                                    rep("25 to 29", 5)),
                          "value" = rnorm(10))

year_now <- as.numeric(substr(Sys.Date(), 1, 4))

# get the number of entries in each column that looks like a year
number_of_year_entries <- source_data %>% 
  # in this case we assume the year column is read in as numeric, though you may
  # not want to make this assumption
  # return TRUE (read by R as a 1) if value is between 1950 and now, 
  # or FALSE (0) if not
  # this first mutate makes all entries of non-numeric columns 'FALSE'
  mutate(across(where(purrr::negate(is.numeric)), ~ FALSE)) %>% 
  # the second mutate makes a value TRUE if it is numeric and between 1950 and now
  mutate(across(where(is.numeric), ~ .x %in% c(1950:year_now))) %>%
  # we can then add up the number of values between 1950 and now for each column          
  summarise(across(where(is.logical), ~ sum(.x)))

# and get the location of the column with the most entries that look like a year
year_column <- which(number_of_year_entries == max(number_of_year_entries))
# rename the identified column
names(source_data)[year_column] <- "year"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


# Join dataframes, do relevant calculations etc
# some useful functions:
# left_join(), right_join, add_row(), filter(), select(), group_by() %>% summarise()
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





