# date: 04/04/2022
# THIS IS A TEMPLATE. It may be that not everything is relevant for your data.
# This script runs on test data so you can look at what everything does line by line

# Type 2 data is complex - multiple rows/columns containing headers
# There may or may not be metadata above the column headings 

# Most comments can (should) be deleted in your file 

# read in data -----------------------------------------------------------------

source_data <- tidyxl::xlsx_cells(paste0(input_folder, "/", filename),
                                  sheets = tabname)

# get the info from above the headers (if there is info there that you want)----

info_cells <- SDGupdater::get_info_cells(source_data, 
                                         first_header_row, 
                                         "xlsx_cells")

year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

# remove info cells and clean character column ---------------------------------
clean_cells <- source_data %>%
  SDGupdater::remove_blanks_and_info_cells(first_header_row) %>%
  dplyr::mutate(character = tolower(str_squish(character))) %>% 
  # dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))
  dplyr::mutate(character = SDGupdater::remove_superscripts(character))

# put data into a more standard format -----------------------------------------
# the code below is just an example - each indicator will be quite different
# there is further guidance on the behead function in the template folder
beheaded <- clean_cells %>%
  unpivotr::behead("left-up", disagg) %>%
  unpivotr::behead("left", disagg_level) %>%
  unpivotr::behead("up-left", unused_header) %>%
  unpivotr::behead("up", type) %>%
  dplyr::select(disagg, disagg_level, type, 
                numeric) # note that unused_header is not included - add it in here if you want to see why
# note that in the process of doing behead, the footnotes are removed

# sometimes you end up with columns that aren't quite what you want,
# if this is the case, put the data in a more sensible format
tidy_data <- beheaded %>% 
  # remove rows containing the words "sample size" in the type column
  filter(!grepl("sample size", type)) %>% 
  # put the different disaggs (sex and age) in their own columns
  pivot_wider(names_from = disagg,
              values_from = disagg_level) %>% 
  janitor::remove_empty(c("rows", "cols"))

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

renamed <- tidy_data %>% 
  SDGupdater::rename_column(primary = "sex", new_name = "sex") %>% 
  SDGupdater::rename_column(primary = "age", new_name = "age") %>% 
  dplyr::rename(value = numeric, # xlsx_cells data is consistent in calling this column numeric
                `housing type` = type) 

# Join dataframes, do relevant calculations etc --------------------------------

# some useful dplyr functions:
# left_join(), right_join, 
# add_row(), filter(), select(), group_by(), summarise()
# pivot_longer(), pivot_wider()


# finalise the csv -------------------------------------------------------------

# You can use the dplyr function `arrange` to order the disaggregations columns
# however this is done by alphanumeric order. So if the order you want is not
# alphanumeric, specify the order here and then you will be able to arrange by 
# this 'fake' columninstead of the real one
age_order <- data.frame(age = c("Under 66", "Over 65",  ""),
                        age_order = c(1:3))

csv_formatted <- renamed %>% 
  # Correct the names of levels of disaggregations, e.g total/UK will nearly always be replaced 
  # with a blank (""). Use case_when() if there are lots of options, or ifelse if there is just one
  mutate(age = 
           case_when(
             age == "all" ~ "",
             age == "< 66" ~ "Under 66",
             age == "> 65" ~ "Over 65",
             # this last line says 'for all other cases, keep Age the way it is
             TRUE ~ as.character(age)),
         sex = ifelse(sex == "all", "", sex),
         # totals should be blank, not e.g. 'all'
         `housing type` = ifelse(grepl("all", `housing type`), "", `housing type`),
         sex = ifelse(sex == "all", "", sex),
         # If value is NA give a reason for why it is blank (as below) or...
         `observation status` = ifelse(is.na(value), "Missing value", "Normal value")
         ) %>% 
  # add columns that don't exist yet (e.g. for SDMX)
  # (you need backticks if the column name has spaces)
  mutate(units = "Number",
         `unit multiplier` = "Thousands") %>% 
  # we changed everything to lowercase at the top of the script, 
  # so now we need to change them back to the correct case
  mutate(across(where(is.character), str_to_sentence)) %>% 
  # if you then have to change country as well:
  # mutate(Country = str_to_title(Country)) %>% 
  
  # we got year from the info above the headers so can put it in here
  mutate(Year = year) %>% 
  # order of disaggregations depend on order they appear, so sort these now
  # arrange will put them in alphanumeric order, so if you dont want these follow the age example here
  left_join(age_order, by = "age") %>% 
  arrange(Year, age_order, sex) %>% 
  # Put columns in the order we want them.
  # this also gets rid of the column age_order which has served its purpose and is no longer needed
  select(Year, `housing type`, age, sex, 
         `observation status`, `units`, `unit multiplier`,
         value)

# finally, put the column names in sentence case
names(csv_formatted) <- str_to_sentence(names(csv_formatted))






