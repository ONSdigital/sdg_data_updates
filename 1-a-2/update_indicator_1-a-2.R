# date: 01/02/2023

# read in data -----------------------------------------------------------------
source_data <- read_excel(paste0(input_folder, "/", filename), sheet = tabname, skip = header_row - 1)

# trim source data into a smaller dataframe ------------------------------------
# reformat column value - make sure these row names match those in the new data table, may change in new years
main_data$`...1` <- gsub("9. Education \\(5\\)", "Education",
                         as.character(main_data$`...1`))

# Select only education and public sector expenditure rows
main_data <- subset(main_data, `...1` %in% c("Education", "Public sector expenditure on services")) %>%
  rename(`Spending category` = `...1`)

# Pivot to longer format (one year per row)
long_data <- main_data %>%
  select(!"1998-99" & !"1999-00") %>%
  pivot_longer("2000-01": most_recent_year, names_to = "Year", values_to = "Value") %>%
  pivot_wider(names_from = "Spending category", values_from = "Value")

# calculate percentage for 3rd row ---------------------------------------------
# convert to numeric
long_data$Education <- as.numeric(long_data$Education)
long_data$`Public sector expenditure on services` <- as.numeric(long_data$`Public sector expenditure on services`)

long_data$Value <- (long_data$Education / long_data$`Public sector expenditure on services`) * 100


# Finalise csv -----------------------------------------------------------------

# Reformat years correctly
long_data$Year <- gsub("-", "/", as.character(long_data$Year))

# add extra columns for SDMX
long_data["Series"] = "Proportion of total government spending on essential services, education"
long_data["Observation status"] = "Normal value"
long_data["Unit multiplier"] = "Units"
long_data["Units"] = "Percentage"

# order columns
csv_formatted <- long_data %>%
  select(all_of(c("Year", "Series", "Observation status",
                                 "Unit multiplier", "Units", "Value")))

# put the column names in sentence case (should already be but just in case it changes)
names(csv_formatted) <- str_to_sentence(names(csv_formatted))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))




