# date: 17/02/2023
# Author: Ali Campbell
# creates csv for countries in UK under 5 child mortality data

# read in data -----------------------------------------------------------------

united_kingdom <- dplyr::filter(source_data, sheet == tabname_UK)


# trim & tidy data -------------------------------------------------------------

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
  behead("left-up", area_code) %>%
  behead("left-up", country) %>%
  behead("left", sex) %>%
  behead("up-left", event) %>%
  select(area_code, country, sex, event, numeric) %>%
  # make wider so that each type of figure is in a different column
  pivot_wider(names_from = event, values_from = numeric) %>%
  # convert df to snake case and remove excess white space
  clean_names() %>%
  clean_strings() %>%
  # rename columns based on a pattern in case specific names change between years
  rename_column(primary = "sex", alternate = ("gender"), new_name = "sex") %>%
  rename_column(primary = c("live", "births"), new_name = "live_births") %>%
  rename_column(primary = c("deaths", "1_4"), new_name = "1_4_deaths") %>%
  rename_column(primary = c("deaths", "infant"), new_name = "infant_deaths") %>%
  # select only the columns we need for calculating rates
  select(area_code, country, sex, live_births, infant_deaths, "1_4_deaths")


# calculations -----------------------------------------------------------------

calculations <- tidy_data %>%
  # Create column for total deaths under 5 years
  mutate(under_5_deaths = infant_deaths + `1_4_deaths`) %>%
  # column for under under 5 death rate per 1000 live births
  mutate(under_5_rate = calculate_valid_rates_per_1000(under_5_deaths, live_births, decimal_places = 5)) %>%
  # for now Northern Ireland rates will need to be blank because the numerator and denominator treat non-residents differently
  # use a pattern to identify Northern Ireland in case of differences in spelling, capitalisation, spaces etc
  mutate(remove_NI = grepl(NI_string, country)) %>%
  # blank out deaths and rates for NI
  mutate(under_5_deaths = ifelse(remove_NI == TRUE, NA, under_5_deaths)) %>%
  mutate(under_5_rate = ifelse(remove_NI == TRUE, NA, under_5_rate)) %>%
  # Observation status column for SDMX
  mutate(`Observation status` = case_when(
    under_5_deaths < 3 | is.na(under_5_deaths) ~ "Missing value; suppressed", 
    under_5_deaths >= 3 & under_5_deaths <= 19 ~ "Low reliability",
    under_5_deaths > 19  ~ "Normal value")) %>% 
  mutate(`Observation status` = ifelse(remove_NI == TRUE,
                                              "Missing value", `Observation status`))


# finalise csv -----------------------------------------------------------------

csv_format <- calculations

# add extra columns for SDMX
csv_format["Unit multiplier"] = "Units"
csv_format["Unit measure"] = "Rate per 1,000 live births"
csv_format["Year"] = year

# put columns in correct order
csv_format <- csv_format %>%
  select(all_of(c("Year", "country", "sex", "area_code", "Observation status",
                  "Unit multiplier", "Unit measure", "under_5_rate")))

# rename columns
csv_format <- csv_format %>%
  rename("Country" = "country", "Sex" = "sex", "GeoCode" = "area_code", "Value" = "under_5_rate")

# blanks for totals
csv_format <- csv_format %>%
  mutate(Sex = ifelse(Sex == "All", "", Sex), Country = ifelse(Country == "United Kingdom", "", Country))

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output_UK <- csv_format %>% 
  mutate(Value = ifelse(is.na(Value), "", as.numeric(Value)))

# make sure numeric
csv_output_UK$Value <- as.numeric(csv_output_UK$Value)

# clean workspace of objects that will be used in E&W script
# (apart from year, as we will use this to select the correct row)
rm(calculations,
   csv_format,
   info_cells,
   main_data,
   tidy_data,
   country)
