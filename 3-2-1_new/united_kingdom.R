# date: 17/02/2023
# Author: Ali Campbell
# creates csv for countries in UK under 5 child mortality data

# read in data -----------------------------------------------------------------

#' The data was read in using the xlsx_cells function in compile_tables.R so that 
#' we can use the behead function below (trim data). This is not strictly necessary 
#' for this table because there is one simple header row. If, in future years it 
#' all goes pear shaped, I've left another simpler method hashed out below

#UK_source_data <- read_excel(paste0(input_folder, "/", filename), sheet = tabname_UK,
                             #skip = header_row_UK - 1)

united_kingdom <- dplyr::filter(source_data, sheet == tabname_UK)


# trim data ----------------------------------------------------------------

#UK_data_trim <- UK_source_data %>%
  #select("Year", "Live births", "Infant under 1 year", "Childhood deaths 1–4 years")

info_cells <- SDGupdater::get_info_cells(united_kingdom, header_row_UK)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- united_kingdom %>%
  mutate(character = str_squish(character)) %>%
  remove_blanks_and_info_cells(header_row_UK) %>%
  mutate(character = suppressWarnings(remove_superscripts(character)))

# tidy data up into a more usable table
tidy_data <- main_data %>%
  # these lines detail the direction of the relevant text for each data point
  unpivotr::behead("left-up", area_code) %>%
  unpivotr::behead("left-up", country) %>%
  unpivotr::behead("left", sex) %>%
  unpivotr::behead("up-left", event) %>%
  dplyr::select(area_code, country, sex, event, numeric) %>%
  # make wider so that each type of figure is in a different column
  pivot_wider(names_from = event, values_from = numeric) %>%
  # select only the columns we need for calculating rates
  select(area_code, country, sex, "Live births", )

# calculations -----------------------------------------------------------------
 
# Create column for total deaths under 5 years

# column for under under 5 death rate per 1000 live births


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




