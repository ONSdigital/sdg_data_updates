# Author: Emma Wood
# Date (start): 26/01/2021
# Purpose: To create csv data for birthweight by mother age disaggregation for indicator 3.2.2
# Requirements: This script is called by compile_tables.R, which is called by update_indicator_main.R


birthweight_by_mum_age <- dplyr::filter(source_data, sheet == birthweight_by_mum_age_tab_name)

info_cells <- SDGupdater::get_info_cells(birthweight_by_mum_age, first_header_row_birthweight_by_mum_age)
year <- SDGupdater::unique_to_string(info_cells$Year)
country <- SDGupdater::unique_to_string(info_cells$Country)

main_data <- birthweight_by_mum_age %>%
  dplyr::mutate(character = str_squish(character)) %>% 
  SDGupdater::remove_blanks_and_info_cells(first_header_row_birthweight_by_mum_age) %>%
  dplyr::mutate(character = suppressWarnings(SDGupdater::remove_superscripts(character)))

tidy_data <- main_data %>%
  unpivotr::behead("left-up", birthweight) %>%
  unpivotr::behead("left", mother_age) %>%
  unpivotr::behead("up-left", measure) %>%
  unpivotr::behead("up-left", event) %>%
  unpivotr::behead("up", baby_age) %>%
  dplyr::select(birthweight, mother_age, measure, event, baby_age,
         numeric)

clean_data <- tidy_data %>%
  dplyr::filter(!is.na(numeric)) %>% # to remove cells that are just ends of a header that have run on to the next row
  dplyr::mutate(birthweight = trimws(birthweight,  which = "both"),
                mother_age = trimws(mother_age, which = "both")) %>%
  dplyr::mutate(birthweight = ifelse(birthweight == "4000 and" | birthweight == "over",
                              "4000 and over", birthweight))

data_for_calculations <- clean_data %>%
  tidyr::pivot_wider(names_from = c(measure, baby_age, event),
              values_from = numeric)

# rename columns so they are the same each year --------------------------------
neonatal_rate_patterns <- c("Rates", "Neo")
live_births_patterns <- c("Live")
early_neonatal_numbers_patterns <- c("Numbers", "Early")
neonatal_numbers_patterns <- c("Numbers", "Neo", "Deaths")

neonatal_rate_column <- which(apply(sapply(neonatal_rate_patterns, grepl, 
                                           names(data_for_calculations)), 1, all) == TRUE)
live_births_column <- which(apply(sapply(live_births_patterns, grepl, 
                                         names(data_for_calculations)), 1, all) == TRUE)
early_neonatal_numbers_column <- which(apply(sapply(early_neonatal_numbers_patterns, grepl, 
                                         names(data_for_calculations)), 1, all) == TRUE)
neonatal_numbers_column <- which(apply(sapply(neonatal_numbers_patterns, grepl, 
                                              names(data_for_calculations)), 1, all) == TRUE)

names(data_for_calculations)[neonatal_rate_column] <- "Neonatal_rate"
names(data_for_calculations)[live_births_column] <- "number_live_births"
names(data_for_calculations)[early_neonatal_numbers_column] <- "number_early_neonatal_deaths"
names(data_for_calculations)[neonatal_numbers_column] <- "number_neonatal_deaths"
#-------------------------------------------------------------------------------

calculations <- data_for_calculations %>%
  dplyr::mutate(number_late_neonatal_deaths = number_neonatal_deaths - number_early_neonatal_deaths) %>%
  dplyr::mutate(Late_neonatal_rate = SDGupdater::calculate_valid_rates_per_1000(number_late_neonatal_deaths,
                                                                                number_live_births, decimal_places),

                Early_neonatal_rate = SDGupdater::calculate_valid_rates_per_1000(number_early_neonatal_deaths,
                                                                                 number_live_births, decimal_places),

         # overall neonatal rates are calculated already in the download, so we can check our calcs against these
         Rates_Neonatal_check = SDGupdater::calculate_valid_rates_per_1000(number_neonatal_deaths,
                                                                           number_live_births, decimal_places))

number_of_rate_calculation_mismatches <- SDGupdater::count_mismatches(
  calculations$Rates_Neonatal_check, calculations$Neonatal_rate)


data_in_csv_format <- calculations %>%
  dplyr::select(birthweight, mother_age,
                Early_neonatal_rate, Late_neonatal_rate, Neonatal_rate) %>%
  tidyr::pivot_longer(
    cols = ends_with("rate"),
    names_to = "Neonatal_period",
    values_to = "Value")

clean_csv_data_birtweight_by_mum_age <- data_in_csv_format %>%
  dplyr::mutate(Neonatal_period = gsub("_rate", "", Neonatal_period),
         Neonatal_period = gsub("_", " ", Neonatal_period),
         Neonatal_period = ifelse(Neonatal_period == "Neonatal", "", Neonatal_period),
         mother_age = gsub("-", " to ", mother_age),
         mother_age = gsub("&", " and ", mother_age),
         mother_age = gsub("<", "Less than ", mother_age),
         mother_age = ifelse(mother_age == "Notstated", "Not stated", mother_age),
         mother_age = ifelse(mother_age == "All", "", mother_age),
         mother_age = trimws(mother_age,  which = "both"),
         birthweight = gsub("-", " to ", birthweight),
         birthweight = gsub("<", "Under ", birthweight),
         # birthweight = ifelse(birthweight == "<", "Under", birthweight),
         birthweight = ifelse(birthweight == "Notstated", "Not stated", birthweight),
         birthweight = ifelse(birthweight == "All", "", birthweight),
         GeoCode = ifelse(country == "England and Wales", "K04000001", ""),
         Country = ifelse(country == "England and Wales", "England and Wales linked deaths", country)) %>%
  dplyr::mutate(mother_age = ifelse(mother_age == "Less than 20", "19 and under", mother_age),
                mother_age = ifelse(mother_age == "40  and  over", "40 and over", mother_age)) %>% 
  dplyr::rename(`Neonatal period` = Neonatal_period,
         Age = mother_age,
         Birthweight = birthweight) %>%
  dplyr::mutate(Year = year,
         Sex = "",
         Region = "",
         `Country of birth` = "")  %>% 
  dplyr::mutate(Value = as.numeric(Value))


SDGupdater::multiple_year_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")
SDGupdater::multiple_country_warning(filename, birthweight_by_mum_age_tab_name,"birthweight by age")

# clean up environment as the same names are used for multiple scripts called in the same session
rm(clean_data,
   data_for_calculations, data_in_csv_format,
   info_cells, 
   tidy_data,
   country, year,
   number_of_rate_calculation_mismatches)

