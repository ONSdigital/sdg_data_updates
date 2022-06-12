# date: 12/06/2022
# THIS IS A TEMPLATE. It may be that not everything is relevant for your data.
# This script runs on test data so you can look at what everything does line by line

# Type 5 data is timeseries data with a 4 digit identification code (CDID) from 
# the ONS website. It does not require a manual download as it 
# has a stable weblink (API is also available here but not used as weblink is 
# more straightforward)
  
# These downloads include metadata that can be used in the markdown file to 
# inform the indictator metadata fields such as release date.

# Most comments can (should) be deleted in your file, and data renamed as approriate 

# to go in SDGupdater:
cdid_split <- function(dat) {
  # Identify the first row of data by the first row in col 1 in which there is a number
  # because the first column should always be year, and all the info in the first 
  # column above the data should be a heading and so not contain a number.
  data_start_row <- min(which(grepl("[0:9]", dat[, 1]) == TRUE))
  
  metadata <- dat[1:data_start_row-1, ]
  
  data <- dat[data_start_row:nrow(dat), ] 
  names(data) <- c("Date", "Value")
  data <- data %>% 
    dplyr::mutate(Value = as.numeric(Value))
  
  output <- list(metadata, data)
  return(output)
}

# download and read in data ----------------------------------------------------
expenditure <- read.csv(expenditure_link) 

gdp <- read.csv(gdp_link) 

# separate data and metadata ---------------------------------------------------
expenditure_metadata <- cdid_split(expenditure)[[1]]
expenditure_data <- cdid_split(expenditure)[[2]] %>% 
  rename(expenditure = Value)

gdp_metadata <- cdid_split(gdp)[[1]]
gdp_data <- cdid_split(gdp)[[2]] %>% 
  rename(gdp = Value)

# join the dataframes and perform calculations ---------------------------------
indicator <- expenditure_data %>% 
  left_join(gdp_data, by = "Date") %>% 
  mutate(Value = (expenditure/gdp)*100)









  
# get the months the years run from and to (to use in QA)- this can be removed
# if data are only published annually. It is included for data published more 
# frequently as a check that the right data have been pulled from nomis 
months <- as.character(unique(numerator_data$DATE_NAME))
months_no_years <- gsub('[[:digit:]]+', '', months)
unique_months <- unique(months_no_years)

# when running back series, we could download just the annual data so that we can download more years at once.
# However, for standard updates we should only need to download the last two years at the most.
# To ensure that we only use the Jan to Dec data (for example), we need to download all quarters.
# This is because the nomis download link is based on the number of quarters since the most recent data.
multiple_quarters <- ifelse(length(unique_months) > 1, TRUE, FALSE)

# if this is a standard update and annual data are available up to different quarters, 
# we need to filter for the data made up to (usually) the end of the calendar year.
# required_month is specified in the config file.
if(multiple_quarters == TRUE) {
  numerator_annual <- numerator_data %>% 
    mutate(keep_quarter = ifelse(substr(DATE_CODE, 6, 7) == required_month, TRUE, FALSE)) %>% 
    filter(keep_quarter == TRUE) %>% 
    select(-keep_quarter)
}

# clean up the numerator data---------------------------------------------------
clean_numerator <- numerator_annual %>% 
  # we don't need confidence intervals - though this may change in future
  filter(MEASURES_NAME == "Value") %>% 
  # split the geographies so country and region are in separate columns
  # and (for this example, we also split the occupation codes into minor group and unit group 
  mutate(
    Country = case_when(
      GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
      GEOGRAPHY_TYPE == "Regions" ~ "England",
      TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, ""),
    # while C_OCCPUK11H_0_NAME currenlty gives the code and the name in one string, 
    # in the next step we fill this column with just the code, so calling this 
    # minor_group_code not `Occupation minor group`
    minor_group_code = ifelse(C_OCCPUK11H_0_TYPE == "3-digit occupation", C_OCCPUK11H_0_NAME,""),
    `Occupation unit group` = ifelse(C_OCCPUK11H_0_TYPE == "4-digit occupation",  C_OCCPUK11H_0_NAME, "")) %>% 
  rename(numerator = OBS_VALUE,
         `Observation status` = OBS_STATUS_NAME) %>% 
  select(DATE_CODE, 
         Country, Region, 
         minor_group_code, `Occupation unit group`, 
         GEOGRAPHY_CODE,
         `Observation status`,
         numerator)

# This example uses occupation codes. For our csvs this kind of data is split
# out into a nested disaggregation - with occupation unit group nested under 
# occupation minor group. In the nomis data, all occupation codes are in a single 
# column. We want them in two columns. In order to make sure the minor group has the 
# correct value when there is a unit group (i.e. not a minor group total), we first 
# create a lookup table:
occupation_lookup <- numerator_annual %>%
  filter(C_OCCPUK11H_0_TYPE == "3-digit occupation") %>%
  distinct(C_OCCPUK11H_0_NAME) %>%
  mutate(CODE = substring(C_OCCPUK11H_0_NAME, 1, 3))

# Fill in Occupation minor group column
occupations_filled <- clean_numerator %>% 
  # the first three numbers of the unit group tell you what the minor group is
  mutate(
    minor_group_code = case_when(
      `Occupation unit group` != "" ~ substr(`Occupation unit group`, 1, 3),
      `Occupation unit group` == "" ~ substr(minor_group_code, 1, 3),
      TRUE ~ as.character(minor_group_code))
    )%>%
  left_join(occupation_lookup, by = c("minor_group_code" = "CODE")) %>% 
  rename(`Occupation minor group` = C_OCCPUK11H_0_NAME) %>% 
  select(-minor_group_code)


# clean up the denominator data-------------------------------------------------

clean_population <- population_data %>% 
  # not all data will be relevant so filter it for what you need
  filter(MEASURES_NAME == "Value" & # don't need confidence intervals
           # the numerator data isn't disaggregated by sex or age, so only need the totals
           SEX_NAME == "Total" &
           AGE_NAME == "All ages") %>%  
  # country and region need to be in separate columns
  mutate(Country = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ GEOGRAPHY_NAME, 
    GEOGRAPHY_TYPE == "Regions" ~ "England",
    TRUE ~ ""),
    Region = ifelse(GEOGRAPHY_TYPE == "Regions", GEOGRAPHY_NAME, "")) %>% 
  rename(population = OBS_VALUE) %>% 
  # make date a string as the date column you later use to join the two 
  # dataframes is a character string
  mutate(DATE_CODE = as.character(DATE_CODE)) %>% 
  # make sure you have filtered for only things you need and that you have selected 
  # all the relevant columns. 
  select(DATE_CODE, 
         Country, Region, 
         population)

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
nrow(distinct(clean_population)) == nrow(clean_population)

# join numerator and denominator data frames and do calculations ---------------

proportion_data <- occupations_filled %>% 
  # In this example, we are using annual data only, but multiple end points are 
  # available in the download (e.g year ending December, year ending march etc).
  # Because all the date_codes have the same month we can remove this information
  # (this would be different if, for example the data were quarterly)
  mutate(Year = substr(DATE_CODE, 1, 4)) %>% 
  left_join(clean_population, by = c("Year" = "DATE_CODE", "Country", "Region")) %>% 
  mutate(Value = (numerator/population) * 10000)

  
# format data for csv file -----------------------------------------------------
csv_formatted <- proportion_data %>% 
  mutate(
    Country = case_when(
      Country == "United kingdom" ~ "", 
      Country == "Northern ireland" ~ "Northern Ireland",
      TRUE ~ as.character(Country)),
    # I have mapped the observation status for these data, however please
    # check that this is correct for your indicator as wording and options 
    # may be different in other data sets
    `Observation status` = case_when(
      `Observation status` == "Estimate and confidence interval not available since the group sample size is zero or disclosive (0-2)" ~ 
        "Missing value; suppressed",
      `Observation status` == "Estimate is less than 500" ~ 
        "Missing value; data exist but were not collected",
      TRUE ~ as.character(`Observation status`))
  ) %>% 
  arrange(Year, Country, Region, `Occupation unit group`, `Occupation minor group`) %>% 
  rename(GeoCode = GEOGRAPHY_CODE) %>% 
  select(Year, `Occupation minor group`, `Occupation unit group`,
         Country, Region, GeoCode, `Observation status`, Value) 

# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))

