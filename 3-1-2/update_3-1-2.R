# date: 03/02/2023

#' Have hashed out old method that was replaced with behead method

# read in data -----------------------------------------------------------------

#source_data <- read_excel(paste0(input_folder, "/", filename), sheet = tabname, skip = header_row - 1)

source_data <- tidyxl::xlsx_cells(paste0(input_folder, "/", filename), sheet = tabname)

info_cells <- get_info_cells(source_data, header_row)
year <- unique_to_string(info_cells$Year)
country <- unique_to_string(info_cells$Country)

main_data <- source_data %>%
  mutate(character = str_squish(character)) %>% 
  remove_blanks_and_info_cells(header_row) %>%
  mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))
  
# create usable table from source data
tidy_data <- main_data %>%
  behead("left-up", no_previous_children) %>%
  behead("left-up", place_of_birth) %>%
  behead("up", mothers_age) %>%
  select(no_previous_children, place_of_birth, mothers_age, numeric) %>%
  # make wider table for calculation later
  pivot_wider(names_from = place_of_birth, values_from = numeric)


# future-proof (hopefully) table -----------------------------------------------

tidy_data_clean <- tidy_data %>%
  # make columns snake case w/o white space
  clean_strings() %>%
  # use this instead of tolower() because it changes non alphanumeric characters
  # to _
  clean_names() %>%
  # rename columns
  rename_column(primary = "total", new_name = "total") %>%
  rename_column(primary = c("nhs"), not_pattern = "non", new_name = "nhs") %>%
  rename_column(primary = c("non", "nhs"), new_name = "non_nhs")

# GOT TO HERE

# clean up text values in place_of_birth
tidy_data_clean$mothers_age <- sapply(tidy_data_clean$mothers_age,
                                           make_clean_names, USE.NAMES = F)

# these lines do essentially the same future-proofing thing as rename_columns 
# above but for the row values of mothers_age
tidy_data_scrubbed <- mutate(tidy_data_clean, mothers_age = 
                                 case_when(grepl("all", mothers_age) ~ "all_ages",
                                           (grepl("under", mothers_age) &
                                              (grepl("20", mothers_age))) ~ "19_and_under",
                                           (grepl("20", mothers_age) & 
                                              grepl("24", mothers_age)) ~ "20_to_24",
                                           (grepl("25", mothers_age) & 
                                              grepl("29", mothers_age)) ~ "25_to_29",
                                           (grepl("30", mothers_age) & 
                                              grepl("34", mothers_age)) ~ "30_to_34",
                                           (grepl("35", mothers_age) & 
                                              grepl("39", mothers_age)) ~ "35_to_39",
                                           (grepl("40", mothers_age) & 
                                              grepl("44", mothers_age)) ~ "40_to_44",
                                           (grepl("45", mothers_age) & 
                                              grepl("over", mothers_age)) ~ "45_and_over",
                                           (grepl("not", mothers_age) & 
                                              grepl("stated", mothers_age)) ~ "not_stated",
                                           TRUE ~ as.character(mothers_age)))

# calculate percentage of births occurring within a medical facility -----------
tidy_data_scrubbed$Value <- ((tidy_data_scrubbed$nhs + tidy_data_scrubbed$non_nhs) / 
                               tidy_data_scrubbed$total) * 100

# finalise csv -----------------------------------------------------------------

csv_formatted <- tidy_data_scrubbed

# Reformat ages
csv_formatted$mothers_age <- gsub("_", " ", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("mothers ", "", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("all ages", "", as.character(csv_formatted$mothers_age))

csv_formatted$no_previous_children <- gsub("Total", "", as.character(csv_formatted$no_previous_children))

# Change column names
csv_formatted <- csv_formatted %>%
  rename("Number of previous live births" = "no_previous_children") %>%
  rename("Age" = "mothers_age")

# add extra columns for SDMX
csv_formatted["Year"] = year
csv_formatted["Series"] = "Births occurring within a medical facility"
csv_formatted["Country"] = ""
csv_formatted["Region"] = ""
csv_formatted["Health Board"] = ""
csv_formatted["Observation status"] = "Normal value"
csv_formatted["Unit multiplier"] = "Units"
csv_formatted["Units"] = "Percentage (%)"
csv_formatted["Geo code"] = ""

# Change the observation status column to be SDMX compatible before we set the NaN values as blank
csv_formatted <- csv_formatted %>%
  mutate('Observation status' = case_when(`Value` == "NaN" ~ "Missing value; data cannot exist",
                                          TRUE ~ "Normal value"))

# Swap NaN for blanks
csv_formatted$Value <- gsub(NaN, "", as.character(csv_formatted$Value))

# Order columns
csv_formatted <- csv_formatted %>%
  select(all_of(c("Year", "Series", "Age", "Number of previous live births", 
                  "Country", "Region", "Health Board", "Observation status",
                  "Unit multiplier", "Units", "Geo code", "Value")))

# put the column names in sentence case
names(csv_formatted) <- str_to_sentence(names(csv_formatted))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
check_all <- nrow(distinct(csv_output)) == nrow(csv_output)



