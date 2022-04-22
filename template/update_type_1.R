# date: 24/03/2022
# THIS IS A TEMPLATE. It may be that not everything is relevant for your data.
# This script runs on test data so you can look at what everything does line by line

# Type 1 data is simple - one row of column headings and no row names
# There may or may not be metadata above the column headings - this code allows for both scenarios

# Most comments can (should) be deleted in your file 

# read in data -----------------------------------------------------------------

source_data <- get_type1_data(header_row, filename, tabname)

# clean the data and get yer and country info from above the headers -----------

# clean_strings() has remove_ss (stands for remove_superscripts) as an argument. 
# The default is TRUE. IMPORTANT: Set to FALSE if there strings of letters that 
# end in a number that you want to keep. Where a number falls at the end of an 
# alphanumeric code, it will  not be interpreted as a superscript and will not 
# be removed. However, if the ONLY number in an alphanumeric code is at the end, 
# the number will be seen as a superscript. 

clean_data <- clean_strings(source_data, remove_ss = TRUE)

metadata <- extract_metadata(clean_data, header_row)

main_data <- extract_data(clean_data, header_row)

# if you import a csv, numbers will now be read as characters - you can rectify this here
# NOTE: check that data types are what you expect after running th
if (header_row > 1){
  main_data <-  main_data %>% 
    type.convert(as.is = TRUE) 
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
# footnotes are in the first 2 (or whatever number you use as the 
#   check_columns argument) columns of the datafame.
#   If there is text in the same row as the footnotes in 
#   columns beyond check_columns, these rows will not be dropped (see ?remove_footnotes)
# if the data are likely to have non-footnote data in the first column(s) but NAs
#   in all other columns DO NOT use this function as it will likely remove more 
#   than just footnotes

main_data <- remove_footnotes(main_data)

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
  rename_column(primary = "age", new_name = "age") %>% 
  rename_column(primary = "all_households", 
                not_pattern = "sample",
                new_name = "all_households_000s") %>% 
  rename_column(primary = c("sample", "size"), alternate = "count", 
                new_name = "sample_size") #%>%
  # # the following isn't something we want to do here, but to show how you
  # # match multiple potential patterns using the OR operator:
  # rename_column(primary = "type", not_pattern = "a|b|c|other",
  #               new_name = "d")
  

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Join dataframes, do relevant calculations etc

# some useful dplyr functions:
# left_join(), right_join, 
# add_row(), filter(), select(), group_by(), summarise()
# pivot_longer(), pivot_wider()

# If, like in type_1_data, you have multiple columns with values, e.g. where each
# holds the values for a level of a disaggregation, pivot_longer is your friend

tidy_data <- renamed_main %>% 
  pivot_longer(
    cols = c(contains("type"), all_households_000s),
    names_to = "type",
    values_to = "value"
  )

# # for doing calculations, you may rather want values in separate columns, but the same row.
# # The reverse of pivot_longer is pivot wider. e.g. if I wanted to add types a and b
# # and the data were already tidy (one value per row)
# calculation_example <- tidy_data %>% 
#   pivot_wider(names_from = "type",
#               values_from = "value") %>% 
#   mutate(type_a_plus_b = as.numeric(type_a) + as.numeric(type_b))
# 
# # then back to tidy:
# example_tidied <- calculation_example %>% 
#   pivot_longer(
#     cols = c(contains("type"), all_households_000s),
#     names_to = "type",
#     values_to = "value"
#   )

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# finalise csv -----------------------------------------------------------------

# make column names sentence case

# add extra columns for SDMX, rename levels of disaggregations, 
# put columns in correct order etc 

# order of disaggregations depend on order they appear. In some cases this won't 
# be alphanumeric order, so specify the order here and arrange by this fake column 
# instead of the real one
age_order <- data.frame(age = c("Under 66", "Over 65",  ""),
                        age_order = c(1:3))

csv_formatted <- tidy_data %>% 
  # rename columns that need renaming
  rename(`housing type` = type) %>%
  # you might want to use the country and year we got from extract_metadata above.
  # These are in a list called metadata. Make sure there is only ONE country / ONE 
  # year given. If so, they can be accessed like this:
  mutate(country = metadata$country) %>% 
  # Correct the names of levels of disaggregations, e.g total/UK will nearly always be replaced 
  # with a blank (""). Use case_when() if there are lots of options, or ifelse if there is just one
  mutate(age = 
           case_when(
             age == "all" ~ "",
             age == "< 66" ~ "Under 66",
             age == "> 65" ~ "Over 65",
             # this last line says 'for all other cases, keep Age the way it is
             TRUE ~ as.character(age)),
         sex = ifelse(sex == "All", "", sex),
         # totals should be blank, not e.g. 'all'
         `housing type` = ifelse(`housing type` == "all_households_000s", "", `housing type`),
         sex = ifelse(sex == "all", "", sex),
         country = ifelse(country == "UK", "", country),
         # If value is NA give a reason for why it is blank (as below) or...
         `observation status` = ifelse(is.na(value), "Missing value", "Normal value")
         ) %>% 
  # you can also use pattern matching to change level names, e.g. removing the 
  # word 'type' fromthe housing types column
  mutate(`housing type` = stringr::str_replace(`housing type`,"type_|_types",  "")) %>% 
  # add columns that don't exist yet (e.g. for SDMX)
  # (you need backticks if the column name has spaces)
  mutate(units = "Number",
         `unit multiplier` = "Thousands") %>% 
  # ... or remove it using filter() as the commented line below
  # filter(!is.na(Value)) %>%
  # we changed everything to lowercase at the top of the script, 
  # so now we need to change them back to the correct case
  mutate(across(where(is.character), str_to_sentence)) %>% 
  # if you then have to change country as well:
  # mutate(Country = str_to_title(Country)) %>% 

  # order of disaggregations depend on order they appear, so sort these now
  # arrange will put them in alphanumeric order, so if you dont want these follow the age example here
  left_join(age_order, by = "age") %>% 
  arrange(year, age_order, sex) %>% 
  # Put columns in the order we want them.
  # this also gets rid of the column age_order which has served its purpose and is no longer needed
  select(year, `housing type`, age, sex, 
         `observation status`, `units`, `unit multiplier`,
         value)

# put the column names in sentence case
names(csv_formatted) <- str_to_sentence(names(csv_formatted))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))




