# date: 22/02/2023
# Author: Ali Campbell
# creates csv for countries in UK under 5 child mortality data

# read in data -----------------------------------------------------------------

england_wales <- dplyr::filter(source_data, sheet == tabname_EW)

# trim & tidy data -------------------------------------------------------------

info_cells <- SDGupdater::get_info_cells(england_wales, header_row_EW)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- england_wales %>%
  mutate(character = str_squish(character)) %>%
  remove_blanks_and_info_cells(header_row_EW) %>%
  mutate(character = suppressWarnings(remove_superscripts(character)))


# tidy data up into a more usable table
tidy_data <- main_data %>%
  # these lines detail the direction of the relevant text for each data point
  behead("left", year) %>%
  behead("up-left", event) %>%
  select(year, event, numeric) %>%
  # make wider so that each type of figure is in a different column
  pivot_wider(names_from = event, values_from = numeric) %>%
  # convert df to snake case and remove excess white space
  clean_names() %>%
  clean_strings() %>%
  # rename columns based on a pattern in case specific names change between years
  rename_column(primary = c("live", "births"), new_name = "live_births") %>%
  rename_column(primary = c("deaths", "1_4"), new_name = "1_4_deaths") %>%
  # can probably use a more general pattern than this but this is the only one 
  # I could get to work for now
  rename_column(primary = c("infant_under_1_year"),
                not_pattern = c("rate"), new_name = "infant_deaths") %>%
  # select only the columns we need for calculating rates
  select(year, live_births, infant_deaths, `1_4_deaths`)

# calculations -----------------------------------------------------------------

calculations <- tidy_data %>%
  # Create column for total deaths under 5 years
  mutate(under_5_deaths = infant_deaths + `1_4_deaths`) %>%
  # column for under under 5 death rate per 1000 live births
  mutate(under_5_rate = calculate_valid_rates_per_1000(under_5_deaths, live_births, decimal_places = 5)) %>%
  # Observation status column for SDMX
  mutate(`Observation status` = case_when(
    under_5_deaths < 3 | is.na(under_5_deaths) ~ "Missing value; suppressed", 
    under_5_deaths >= 3 & under_5_deaths <= 19 ~ "Low reliability",
    under_5_deaths > 19  ~ "Normal value"))


# finalise csv -----------------------------------------------------------------

csv_format <- calculations

# add extra columns for SDMX
csv_format["Unit multiplier"] = "Units"
csv_format["Unit measure"] = "Rate per 1,000 live births"
csv_format["Country"] = "England and Wales"
csv_format["Sex"] = ""
csv_format["GeoCode"] = england_wales_geocode

# put columns in correct order
csv_format <- csv_format %>%
  select(all_of(c("year", "Country", "Sex", "GeoCode", "Observation status",
                  "Unit multiplier", "Unit measure", "under_5_rate")))

# rename columns
csv_format <- csv_format %>%
  rename("Year" = "year", "Value" = "under_5_rate")

csv_filtered <- csv_format %>%
  filter(Year == year)

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output_EW <- csv_filtered %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))
