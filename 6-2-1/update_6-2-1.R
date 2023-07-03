# date: 24/03/2022
# THIS IS A TEMPLATE. It may be that not everything is relevant for your data.
# This script runs on test data so you can look at what everything does line by line

# Type 1 data is simple - one row of column headings and no row names
# There may or may not be metadata above the column headings - this code allows for both scenarios
readr::read_csv
# Most comments can (should) be deleted in your file 

# read in data -----------------------------------------------------------------
#source__data_washdash <- readr::read_csv(file = paste0(input_folder"/","washdash_download.csv"))
source_washdash <- readr::read_csv('sdg_data_updates/6-2-1/example_Input/washdash_download.csv')
#source_data_facility <- readr::read_csv(file = paste0("Input/", filename_facility))
#source_data_safe <- readr::read_csv(file = paste0("Input/", filename_safe))
#source_data-service <- readr::read_csv(file = paste0("Input/", filename_service))                                   
#source_data1 <- get_type1_data(header_row = 1, filename = filename1)
# clean the data and get yer and country info from above the headers -----------



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

tidy_data <- renamed_main %>% 
  pivot_longer(
    cols = c(contains("type"), all_households_000s),
    names_to = "type",
    values_to = "value"
  )



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




