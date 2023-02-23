# date: 03/02/2023

# read in data -----------------------------------------------------------------

source_data <- read_excel(paste0(input_folder, "/", filename), sheet = tabname, skip = header_row - 1)

# format table  to long format -------------------------------------------------


source_data_clean <- source_data %>%
  # make columns snake case w/o white space
  clean_strings() %>%
  # use this instead of tolower() because it changes non alphanumeric characters
  # to _
  clean_names() %>%
  # rename columns
  rename_column(primary = c("number", "previous", "children"), alternate = c("born", "children"),
                new_name = "no_previous_children") %>%
  rename_column(primary = c("place", "of", "birth"), alternate = "birth", 
                new_name = "place_of_birth") %>%
  rename_column(primary = c("all", "ages"), 
                new_name = "mothers_all_ages") %>%
  rename_column(primary = c("under", "20"), alternate = "under", 
                new_name = "mothers_under_20") %>%
  rename_column(primary = c("20", "24"), 
                new_name = "mothers_20-24") %>%
  rename_column(primary = c("25", "29"), 
                new_name = "mothers_25-29") %>%
  rename_column(primary = c("30", "34"), 
                new_name = "mothers_30-34") %>%
  rename_column(primary = c("35", "39"), 
                new_name = "mothers_35-39") %>%
  rename_column(primary = c("40", "44"), 
                new_name = "mothers_40-44") %>%
  rename_column(primary = c("45", "over"), 
                new_name = "mothers_over_45") %>%
  rename_column(primary = c("age", "not", "stated"), 
                new_name = "mothers_age_not_stated")

# clean up text values in place_of_birth
source_data_clean$place_of_birth <- sapply(source_data_clean$place_of_birth,
                                           make_clean_names, USE.NAMES = F)

# these lines do essentially the same future-proofing thing as rename_columns 
# above but for the row values of place_of_birth
source_data_scrubbed <- mutate(source_data_clean, place_of_birth = 
                                 case_when(grepl("total", place_of_birth) ~ "total",
                                           (grepl("nhs", place_of_birth) &
                                              !(grepl("non", place_of_birth))) ~ "nhs",
                                           (grepl("non", place_of_birth) & 
                                              grepl("nhs", place_of_birth)) ~ "non_nhs",
                                           TRUE ~ as.character(place_of_birth)))

# Select only rows containing these Place of birth values
main_data <- source_data_scrubbed %>%
  subset(place_of_birth %in% c("total", "nhs", "non_nhs"))

# GOT TO HERE

# Long format
long_data <- main_data %>%
  pivot_longer(mothers_all_ages: mothers_age_not_stated, names_to = "mothers_age", # Not bothering with apostrophes as live data doesn't either
               values_to = "Number") %>%
  pivot_wider(names_from = place_of_birth, values_from = "Number")  # pivot wider here to make calculating percentages easier

# calculate percentage of births occurring within a medical facility -----------

long_data$Value <- ((long_data$`NHS establishments` + long_data$`Non-NHS establishments`) / long_data$Total) * 100

# finalise csv -----------------------------------------------------------------

csv_formatted <- long_data

# Reformat ages
csv_formatted$mothers_age <- gsub("_", " ", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("mothers ", "", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("all ages", "", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("under 20", "19 and under", as.character(csv_formatted$mothers_age))
csv_formatted$mothers_age <- gsub("age not stated", "not stated", as.character(csv_formatted$mothers_age))

csv_formatted$number_of_previous_live_born_children <- gsub("Total", "", as.character(csv_formatted$number_of_previous_live_born_children))

# Change column names
csv_formatted <- csv_formatted %>%
  rename("Number of previous live births" = "number_of_previous_live_born_children") %>%
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



