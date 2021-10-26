# Author: Emma Wood
# Date (start): 01/02/2021
# Purpose: To create csv data for area of residence (region) 3.2.2.
# TO DO: look into also giving local authority numbers (We shouldn't display rates as they are unreliable)
# Requirements:This script is called by compile_tables.R, which is called by update_indicator_main.R

area_of_residence <- dplyr::filter(source_data, sheet == area_of_residence_tab_name)

# info cells are the cells above the column headings
info_cells <- SDGupdater::get_info_cells(area_of_residence, first_header_row_area_of_residence)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- area_of_residence %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  SDGupdater::remove_blanks_and_info_cells(first_header_row_country_by_sex) %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

if ("Region" %in% main_data$character){ # because headings are different for 2017 and 2018 files
  tidy_data <- main_data %>%
    unpivotr::behead("left-up", GeoCode) %>%
    unpivotr::behead("left-up", area_name) %>%
    unpivotr::behead("left-up", geography) %>%
    unpivotr::behead("up-left", measure) %>%
    unpivotr::behead("up-left", life_event) %>%
    unpivotr::behead("up", baby_age) %>%
    dplyr::select(GeoCode, area_name, geography, measure, life_event, baby_age,
                  numeric)

  clean_data <- tidy_data %>%
    dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
    dplyr::mutate(area_name = trimws(area_name,  which = "both"),
                  geography = trimws(geography,  which = "both"))

  only_regions_kept <- clean_data %>%
    dplyr::filter(geography == "Region")

} else if(year < 2015){ # for data that don't have Region as a geography, England regions and Welsh health boards are in the same column

  tidy_data <- main_data %>%
    unpivotr::behead("left-up", area_name) %>%
    unpivotr::behead("up-left", measure) %>%
    unpivotr::behead("up-left", life_event) %>%
    unpivotr::behead("up", baby_age) %>%
    dplyr::select(area_name, measure, life_event, baby_age,
                  numeric) %>% 
    dplyr::mutate(GeoCode = "")
  
  clean_data <- tidy_data %>%
    dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
    dplyr::mutate(area_name = trimws(area_name,  which = "both"))

  only_regions_kept <- clean_data %>% # because Wales health boards and LAs contain lowercase letters
    dplyr::filter(grepl("[a-z]|ENGLAND|WALES|SCOTLAND", area_name) == FALSE)
} else {
  tidy_data <- main_data %>%
    unpivotr::behead("left-up", GeoCode) %>%
    unpivotr::behead("left-up", area_name) %>%
    unpivotr::behead("up-left", measure) %>%
    unpivotr::behead("up-left", life_event) %>%
    unpivotr::behead("up", baby_age) %>%
    dplyr::select(GeoCode, area_name, measure, life_event, baby_age,
                  numeric)
  
  clean_data <- tidy_data %>%
    dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
    dplyr::mutate(area_name = trimws(area_name,  which = "both"))
  
  only_regions_kept <- clean_data %>% # because Wales health boards and LAs contain lowercase letters
    dplyr::filter(grepl("[a-z]|ENGLAND|WALES|SCOTLAND", area_name) == FALSE)
}

# no early-neonatal deaths are given, so can't calculate late_neonatal as in other tables
# but do need to add observation status
data_for_calculations <- only_regions_kept %>%
  tidyr::pivot_wider(names_from = c(measure, baby_age, life_event),
                     values_from = numeric)

# rename columns so they are the same each year --------------------------------
neonatal_rate_patterns <- c("Rates", "Neo")
live_births_patterns <- c("Live")
neonatal_numbers_patterns <- c("Numbers", "Neo", "Deaths")

neonatal_rate_column <- which(apply(sapply(neonatal_rate_patterns, grepl, 
                                           names(data_for_calculations)), 1, all) == TRUE)
live_births_column <- which(apply(sapply(live_births_patterns, grepl, 
                                         names(data_for_calculations)), 1, all) == TRUE)
neonatal_numbers_column <- which(apply(sapply(neonatal_numbers_patterns, grepl, 
                                              names(data_for_calculations)), 1, all) == TRUE)

names(data_for_calculations)[neonatal_rate_column] <- "Neonatal_rate"
names(data_for_calculations)[live_births_column] <- "number_live_births"
names(data_for_calculations)[neonatal_numbers_column] <- "number_neonatal_deaths"
#-------------------------------------------------------------------------------

calculations_region <- data_for_calculations %>%
  dplyr::mutate(obs_status_neonatal = case_when(
      number_neonatal_deaths < 3 | is.na(number_neonatal_deaths) ~ "Missing value; suppressed", 
      number_neonatal_deaths >= 3 & number_neonatal_deaths <= 19 ~ "Low reliability",
      number_neonatal_deaths > 19  ~ "Normal value"))

data_in_csv_format <- calculations_region %>%
  dplyr::select(GeoCode, area_name, 
                Neonatal_rate,
                obs_status_neonatal) 

clean_csv_data_area_of_residence <- data_in_csv_format %>%
  dplyr::rename(Region = area_name,
                Value = Neonatal_rate,
                `Observation status` = obs_status_neonatal) %>%
  dplyr::mutate(Year = year,
                Sex = "",
                `Neonatal period` = "",
                Birthweight = "",
                Age = "",
                `Country of birth` = "", 
                Country = "England",
                Region = SDGupdater::format_region_names(Region))

SDGupdater::multiple_year_warning(filename, area_of_residence_tab_name,"area of residence (region)")
SDGupdater::multiple_country_warning(filename, area_of_residence_tab_name,"area of residence (region)")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(clean_data,
   only_regions_kept,
   info_cells,
   tidy_data,
   country, year)


