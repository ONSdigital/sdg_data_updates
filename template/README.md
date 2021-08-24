## Template R code
  
The code in this folder has been pulled together to make the process of writing automations in R faster and more consistent across indicators. 
It also contains bits of code that aid in future-proofing against changes in the initial files.
  
There are four main files that should be relatively consistent in what they do across all indicators (where it is just a standard update):
1. `update_indicator_main.R` This file is the control script for ALL standard R updates. 
You should not need to change anything on it, other than the indicator number when you are testing your automation
2. `compile_tables.R` Every standard R update needs a script with this exact name. It is the script called by `update_indicator_main.R`, 
and which calls the scripts that do the donkey-work. The csv may be saved from here. The Rmarkdown html file is run and saved from here.
3. `config.R` This could be written as a yaml, but usually the configs are straightforward enough that an R config file is fine. This is where
user configurations are set - these are aspects of the code that may need to be changed depending on when it is run, but that we can't or don't want to automate.
It should have this name to save any confusion, and because this is a standard name for this kind of file. It is called by `compile_tables.R`
4. A .R script or scripts that do the bulk of the work called by `compile_tables.R`. In this template folder, the template script is called `update_x-x-x.R`.
It/they can be called anything, but try to keep it informative.
5. A .Rmd script that creates an html for QA purposes (not yet in templates) called by `compile_tables.R`.
  
## Code for main script
This is just the code in `update_x-x-x.R`. It is displayed here in a way that is hopefully easier to read, and with a bit more explanation.  
  
### Code just for data with complex headers
e.g. merged cells, multiple rows of headings, headings down the side as well as along the top:
![complex_header](https://user-images.githubusercontent.com/52452377/130663339-d953d7ee-13d1-4422-aa48-e8d6091285d0.jpg)
  
1. Read in data

``` 
source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", filename),
                                            sheet = tabname, colNames = FALSE) %>% 
 # change factors to characters as each level of a factor is given a number and so doesn't behave like a string
 mutate(across(where(is.factor), as.character)) %>% 
 # change all strings to lowercase so that if the case is different in the future the code will still work
 mutate(across(where(is.character), tolower)) %>% 
 # remove all trailing white space and change multiple spaces to single spaces within the string
 mutate(across(where(is.character), str_squish))
```

2. Remove blanks and rows above the first header row  
first_header_row is the first row on which there are column names in the excel file  
define first_header_row in config.R (it is the row number)  
```
main_data <- source_data %>% 
  mutate(is_blank = ifelse(character == "" & data_type == "character", TRUE, is_blank)) %>% 
 filter(is_blank == FALSE & row %not_in% 1:(first_header_row - 1))
```

alternatively you could use:
```
tidy_data <- source_data %>%
  SDGupdater::remove_blanks_and_info_cells(first_header_row)
```
This is exactly the same as the previous chunk but with a warning if the data has not been imported correctly.
It is also arguably easier to understand (more explicit) and shorter.

3. Put data in a tidy format
see [unpivotr_behead_explanation.pptx](https://github.com/ONSdigital/sdg_data_updates/blob/main/template/unpivotr_behead_explanation.pptx) for how this works

An example from 3-2-2:
```
tidy_data <- main_data %>% 
  unpivotr::behead("left-up", birthweight) %>%
  unpivotr::behead("left", mother_age) %>%
  unpivotr::behead("up-left", measure) %>%
  unpivotr::behead("up-left", event) %>%
  unpivotr::behead("up", baby_age) %>%
  dplyr::select(birthweight, mother_age, measure, event, baby_age,
                numeric)
  ```


### Code just for data with simple headers
i.e. a single row of column names, with no headings on the side, and no merged cells

1. Read in data
  
If you are not sure whether the top row will always contain the column names, 
use `source_data <- read.csv(paste0(input_folder, "/", filename), header = FALSE)`
or `source_data <- readxl::read_excel(paste0(input_folder, "/", filename), col_names = FALSE)`
```   
source_data <- read.csv(paste0(input_folder, "/", filename)) %>% 
  # change factors to characters as each level of a factor is given a number and so doesn't behave like a string
  mutate(across(where(is.factor), as.character)) %>% 
  # change all strings to lowercase so that if the case is different in the future the code will still work
  mutate(across(where(is.character), tolower)) %>% 
  # remove all trailing white space and change multiple spaces to single spaces within the string
  mutate(across(where(is.character), str_squish))
```

2. Make all column names of all datasets the same case
You can make it whatever case you like, this is just so that it is consistent across years, and across datasets used for the indicator.
You probably don't need to do this to data with complex headings, as you make up the headings yourself when 'beheading' the data.
```
names(source_data) <- tolower(names(source_data))
```

3. Remove trailing and extra dots in names 
read.csv changes spaces in column names to periods. This code can be used to remove excess dots.
So you can see how it works this is some toy data:
```
source_data <- data.frame("one.dot"= c(1, 2),
                          "two..dots" = c(3, 4),
                          "three...dots" = c(3, 4),
                          "end.dots.." = c(7, 8),
                          "..start.dots" = c(7, 8),
                          "..loads....of.dots...." = c(5, 6))
```
We want to replace multiple dots with a single dot.  
`.` in regular expressions means 'everything'
so we have to escape this meaning using `\\`. A regular expression followed by a 
plus sign (`+`) matches one or more occurrences of the one-character regular expression.
```
names(source_data) <- str_replace_all(names(source_data), "\\.\\.+", ".")
```

We also want to replace start dots and end dots with nothing ("").   
In regular expressions `^` means 'at the start' while `$` means 'at the end'.
```
names(source_data) <- str_replace_all(names(source_data), "^\\.|\\.$", "")
```

4. Get the location of the column names row 
If the column names are not in the first row, you could ask the user to define
what this is in the config file. ALTERNATIVELY, you could automate this step, by using a 
word that will definitely be in the column names:
    
When you read in data using `read.csv(..., header = FALSE)`, R gives the columns
the number of the column preceded with a V ("V1", "V2", etc). 
`readxl::read_excel(..., col_names = FALSE)`, gives column number preceded by "...",
so you know what these column names will be.
Toy data:
```
source_data <- data.frame("v1" = c("data source:","","year", "2010", "2010"),
                          "v2" = c("ONS", "", "value", "13293026.32", "1432976.41")) %>% 
  mutate(v1 = as.character(v1),
         v2 = as.character(v2))
```
First, identify which row contains headers using a header you know will be there
```
header_row <- which(source_data$v1 == "year")
```
Then change the column names to be the same as the identified row
```
names(source_data) <- source_data[header_row, ]
```

And subset the data so that any rows above the header row are dropped.
```
source_data <- source_data[header_row + 1:nrow(source_data), ]
```

This results in a datframe the same length as the original, but with lots of 
NAs at the bottom. One way to drop these new but pointless rows is to subset again 
(you could tag this subset onto the end of the last line):
```
source_data <- source_data[1 : (nrow(source_data) - header_row), ]
```

### Code for all data (whether it had complex or simple headings)

1. Remove superscripts 

If there are superscripts in column names, this will impact the way the code runs, unless 
you rename the column (see below). Superscripts in cell contents also have the
potential to impact the way the code runs.   
    
**DO NOT USE remove_superscripts()** if there are cells containing words that end 
in a number:   
It won't usually remove a number from the end of an alphanumeric code, 
but will do so if the ONLY number is at the end
  
Some toy data:
```
source_data <- data.frame("country code1" = c("e92000001", "n92000002"),
                         "country name" = c("england2", "northern ireland"),
                         "areahect" = c(13293026.32, 1432976.41))
```
You can use a function in SDGupdater to remove superscripts from column names.   
**Note: this function may need more testing** so make sure to check it has only 
removed superscripts (not numbers that you want to keep)
```
names(source_data) <- SDGupdater::remove_superscripts(names(source_data))
```

You can also use this function to remove superscripts from all columns. (Same caution notes apply) 
```
source_data <- source_data %>% 
  mutate(across(everything(), ~ SDGupdater::remove_superscripts(.x)))
```
2. make column names consistent across years
There may be column names in the source data that are likely to change in the future, 
or have changed in the past.
This will cause the code to break, as we refer to specific column names in the code, 
and if they don't exist, errors will be thrown.  
You can get around this by identifying the location of the column based on something you know about the name, or
about the data it contains, that doesn't apply to any other column. 
    
First identify the location of the column that needs to be renamed. You may be
able to do this based on 1) part of the column name e.g. geospatial data may have
column names like "CTRY20CD" in 2020 which becomes "CTRY21CD" in 2021. Alternatively
you may be able to 2) identify a column based on it's contents. e.g the "year" 
column could be identified as having a 4 digit number between 1950 and the current
year (which you could extract from `sys.Date()`) in every filled cell.   
    
NOTE: Make sure that whatever criteria you pick, it onlu applies to the column in question
and no other.
    
Some toy data:
```
source_data <- data.frame("ctry20cd" = c("e92000001", "n92000002"),
                           "ctry20nm" = c("england", "northern ireland"),
                           "areahect" = c(13293026.32, 1432976.41))
```
Option 1) Identify the column based on a pattern in the column name and    
get the column index (the number of the column) that fulfills your conditions. 
```
# In this case the conditions are that the first four characters are "ctry" and 
# the 7th to 8th characters are "nm"
country_column <- which(substr(names(source_data), 1, 4) == "ctry" &
                          substr(names(source_data), 7, 8) == "nm")
````

Rename the identified column:
```
names(source_data)[country_column] <- "country"
```

Option 2) Identify the column based on the column contents. In this example, identify year
based on the criteria that all cells are a number between 1950 and the current year
Toy data:
```
source_data <- data.frame("date" = rep(c(2010:2014), 2),
                          "age" = c(rep("20 to 24", 5,),
                                    rep("25 to 29", 5)),
                          "value" = rnorm(10))
```
Get the current year (don't hardcode this!)
```year_now <- as.numeric(substr(Sys.Date(), 1, 4))```

This may be a rather complicated way to go about this! Apologies.
Get the number of entries in each column that looks like a year:
```
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
```
And finally, you can now get the location of the column with the most entries that look like a year
and rename the identified column
```
year_column <- which(number_of_year_entries == max(number_of_year_entries))
names(source_data)[year_column] <- "year"
```

#-------------------------------------------------------------------------------

At this point, most of the future-proofing is done.    
You can now do the stuff that is particularly specific to the indicator, such as 
joining dataframes, doing relevant calculations, etc.    
     
Some useful functions:
```
# join datasets, keeping all the rows in the first dataset:
left_join(join_this_data, to_this_data, by = c("this variable", "and this variable"))  

# join datasets, keeping all the rows in the second dataset
right_join(join_this_data, to_this_data, by = c("this variable", "and this variable"))

# join datasets, keeping all the rows in both datasets
full_join(join_this_data, to_this_data, by = c("this variable", "and this variable")) 

# not often used but you can use this to manually add a row to the data
add_row() 

# remove rows based on some argument, eg filter(sex == "M" | sex == "F") will remove all entries that aren't either "M" or "F"
filter() 

# remove (using `-` before the column name) or keep (just use the column name) columns. Can also be used to order columns
select()

group_by() %>% summarise()

pivot_longer() and pivot_wider()
```
#-------------------------------------------------------------------------------


### Finalise the csv file

Add extra columns for SDMX, rename levels of disaggregations, 
put columns in correct order etc 

The order of disaggregations depend on order they appear. In some cases this won't 
be alphanumeric order, so specify the order here and arrange by this fake column 
instead of the real one
```
age_order <- data.frame(Age = c("Under 15", "16 to 40", "41 to 65", "Over 65"),
                        Age_order = c(1:4))
```
age_order can then be joined to the main data and used by the `arrange()` function (see below):
```
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
```

