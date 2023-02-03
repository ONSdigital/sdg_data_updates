# date: 03/02/2023

# read in data -----------------------------------------------------------------

source_data <- read_excel(paste0(input_folder, "/", filename), sheet = tabname, skip = header_row - 1)

# format table  to long format -------------------------------------------------

# Select only rows containing these Place of birth values
main_data <- subset(source_data, `Place of birth` %in% c("Total", "NHS establishments", "Non-NHS establishments"))

# clean up the column names (snake case, lowercase, no trailing dots etc.)
main_data <- clean_names(main_data)

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
                  "Unit multiplier", "Units", "Value")))

# put the column names in sentence case
names(csv_formatted) <- str_to_sentence(names(csv_formatted))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))




