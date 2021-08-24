# author: Emma Wood
# date: 24/08/2021
# THIS IS A TEMPLATE NOT A WORKING SCRIPT

# read in data------------------------------------------------------------------
# for data with complex headings
source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                            sheet = tabname, colNames = FALSE) %>% 
  # change factors to characters as each level of a factor is given a number and so doesn't behave like a string
  mutate(across(where(is.factor), as.character)) %>% 
  # change all strings to lowercase so that if the case is different in the future the code will still work
  mutate(across(where(is.character), tolower)) %>% 
  # remove all trailing white space and change multiple spaces to single spaces within the string
  mutate(across(where(is.character), str_squish))


# for data with simple headings (a single row of column names, with no headings 
# on the side, and no merged cells)
# If you are not sure whether the top row will always contain the column names, 
# use source_data <- read.csv(paste0(input_folder, "/", filename), header = FALSE)
source_data <- read.csv(paste0(input_folder, "/", filename)) %>% 
  # change factors to characters as each level of a factor is given a number and so doesn't behave like a string
  mutate(across(where(is.factor), as.character)) %>% 
  # change all strings to lowercase so that if the case is different in the future the code will still work
  mutate(across(where(is.character), tolower)) %>% 
  # remove all trailing white space and change multiple spaces to single spaces within the string
  mutate(across(where(is.character), str_squish))

#-------------------------------------------------------------------------------
# make all column names of all datasets the same case---------------------------
names(source_data) <- tolower(names(source_data))

# remove trailing and extra dots in names --------------------------------------
# read.csv changes spaces in column names to periods. Remove excess dots
source_data <- data.frame("one.dot"= c(1, 2),
                          "two..dots" = c(3, 4),
                          "three...dots" = c(3, 4),
                          "end.dots.." = c(7, 8),
                          "..start.dots" = c(7, 8),
                          "..loads....of.dots...." = c(5, 6))
# replace multiple dots with a single dot (. in regular expressions means 'everything'
# so we have to escape this meaning using \\. A regular expression followed by a 
# plus sign (+) matches one or more occurrences of the one-character regular expression)
names(source_data) <- str_replace_all(names(source_data), "\\.\\.+", ".")

# replace start dots and end dots with nothing ("")
# In regular expressions ^ means at the start while $ means at the end) 
names(source_data) <- str_replace_all(names(source_data), "^\\.|\\.$", "")

#-------------------------------------------------------------------------------
# Remove superscripts ----------------------------------------------------------

# if there are superscripts in column names, this will impact the code, unless 
# you rename the column (see below). Superscripts in cell contents also have the
# potential to impact the code.

# DO NOT USE remove_superscripts() if there are cells containing words that end 
#   in a number:
#   It won't usually remove a number from the end of an alphanumeric code, 
#   but will do so if the ONLY number is at the end

source_data <- data.frame("country code1" = c("e92000001", "n92000002"),
                          "country name" = c("england2", "northern ireland"),
                          "areahect" = c(13293026.32, 1432976.41))

# Use function in SDGupdater to remove superscripts from column names 
# (note: this function may need more testing)
names(source_data) <- SDGupdater::remove_superscripts(names(source_data))

# Use function in SDGupdater to remove superscripts from all columns 
# (note: this function may need more testing)
source_data <- source_data %>% 
  mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))

#-------------------------------------------------------------------------------
# get the location of the column names -----------------------------------------
# If the column names are not in the first row, you could ask the user to define
# what this is in the config file, OR you could automate this step, by using a 
# word that will definitely be in the column names.

# when you read in data using read.csv(..., header = FALSE), R gives the columns
# the number of the column preceded with a V ("V1", "V2", etc). 
# readxl::read_excel(..., col_names = FALSE), gives column number preceded by "...",
# so you can predict what these column names will be.
source_data <- data.frame("v1" = c("data source:","","year", "2010", "2010"),
                          "v2" = c("ONS", "", "value", "13293026.32", "1432976.41")) %>% 
  mutate(v1 = as.character(v1),
         v2 = as.character(v2))

# identify which row contains headers using a header you know will be there
header_row <- which(source_data$v1 == "year")

# change the column names to be the same as the identified row
names(source_data) <- source_data[header_row, ]

# subset the data so that any rows above the header row are dropped.
# This results in a datframe the same length as the original, but with lots of 
# NAs at the bottom
source_data <- source_data[header_row + 1:nrow(source_data), ]

# One way to drop these new but pointless rows is to subset again 
# (you could tag this subset onto the end of the last line):
source_data <- source_data[1 : (nrow(source_data) - header_row), ]

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

# 1) identify column based on column name 
source_data <- data.frame("ctry20cd" = c("e92000001", "n92000002"),
                           "ctry20nm" = c("england", "northern ireland"),
                           "areahect" = c(13293026.32, 1432976.41))

# get the column index (the number of the column) that fulfills your conditions. 
# In this case the conditions are that the first four characters are "ctry" and 
# the 7th to 8th characters are "nm"
country_column <- which(substr(names(source_data), 1, 4) == "ctry" &
                          substr(names(source_data), 7, 8) == "nm")

# you may want to duplicate and rename your dataframe though this is not necessary
new_data <- source_data 
# rename the identified column
names(new_data)[country_column] <- "country"

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





