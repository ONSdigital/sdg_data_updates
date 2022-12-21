# author: Katie Uzzell
# date: 14/07/2022

# Code to automate data update for indicator 15-7-1 and 15-c-1 (number of endangered species seizures)

# read in data 

seizures_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

seizures_main_data <- extract_data(seizures_source_data, header_row)

# remove superscripts from column names
# DO NOT use if there are column names containing words that end 
#   in a number: It won't usually remove a number from the end of an alphanumeric code, 
#   but will do so if the ONLY number is at the end)
names(seizures_main_data) <- SDGupdater::remove_superscripts(names(seizures_main_data)) 

# clean up the column names (snake case, lowercase, no trailing dots etc.)
seizures_main_data <- clean_names(seizures_main_data)

seizures_main_data <- janitor::remove_empty(seizures_main_data, which = "cols")

renamed_seizures_main_data <- seizures_main_data %>% 
  rename_column(primary = "Number of Times seized: Caviar & Caviar extract", new_name = "Caviar & Caviar extract") %>% 
  rename_column(primary = "Number of Times seized: Live Coral & Coral Derivatives", new_name = "Live Coral & Coral Derivatives") %>% 
  rename_column(primary = "Number of Times seized: Ivory and Items Containing Ivory", new_name = "Ivory and Items Containing Ivory") %>% 
  rename_column(primary = "Number of Times seized: Live Animals and Birds", new_name = "Live Animals and Birds") %>%
  rename_column(primary = "Number of Times seized: Live Plants", new_name = "Live Plants") %>%
  rename_column(primary = "Number of Times seized: Parts or Derivatives of Animals/Birds", new_name = "Parts or Derivatives of Animals/Birds") %>%
  rename_column(primary = "Number of Times seized: Parts or Derivatives of Plants", new_name = "Parts or Derivatives of Plants") %>%
  rename_column(primary = "Number of Times seized: Timber or Wood Products", new_name = "Timber or Wood Products") %>%
  rename_column(primary = "Number of Times seized: Preparations Of Oriental Medicine Which Include Parts & Derivatives Of Endangered Species", new_name = "Preparations Of Oriental Medicine Which Include Parts & Derivatives Of Endangered Species") %>%
  rename_column(primary = "Number of Times seized: Butterflies", new_name = "Butterflies") 
  

renamed_seizures_main_data[c('Year', 'Quarter')] <- str_split_fixed(renamed_seizures_main_data$Quarter, ' ', 2)


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

tidy_seizures_main_data <- seizures_main_data %>% 
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
seizure_type <- data.frame(seizure_type = c("Caviar & Caviar extract", 
                                            "Live Coral & Coral Derivatives", 
                                            "Ivory and Items Containing Ivory", 
                                            "Live Animals and Birds", "Live Plants", 
                                            "Parts or Derivatives of Animals/Birds", 
                                            "Parts or Derivatives of Plants", 
                                            "Timber or Wood Products", 
                                            "Preparations Of Oriental Medicine Which Include Parts & Derivatives Of Endangered Species", 
                                            "Butterflies",  ""),
                           seizure_type = c(1:3))

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
