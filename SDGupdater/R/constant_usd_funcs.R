#' Convert GBP to constant USD
#'
#' Uses exchange rates and deflators to convert GBP values to constant USD.
#' Exchange rate and deflator data used to convert GBP to Constant USD are from
#' the "data tables section" of 
#' [Development finance data - OECD](https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/).  
#'   
#' To use this function you will first need to download 
#' [Annual Exchange Rates for DAC Donor Countries](https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/Exchange-rates.xls)
#' and "Deflators for Resource Flows from DAC Countries" (the base year and thus
#' url changes with each update, so no url is given for this one).
#' Save both as xlsx files (they are currently downloaded as xls files).  
#'   
#' The constant USD conversion is done using 
#' [methodology](https://www.oecd.org/dac/financing-sustainable-development/development-finance-standards/informationnoteonthedacdeflators.htm) 
#' specified by the OECD. 
#' The GBP values are converted with the USD exchange rate for the respective 
#' year, and then a deflator is applied to transform the current USD values to 
#' constant USD values. See the filename of the deflators data on 
#' [Development finance data](https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/)
#' for the base year.
#'
#' @param rates_filepath Filepath of the exchange rates xlsx file - see link in 
#' description. 
#' @param deflators_filepath Filepath of the deflators dataframe - see link in 
#' description.
#' @param gbp_data Dataframe with year and value as columns 
#' (case is unimportant). Value should be GBP
#' @param unit_multiplier String that follows "Constant USD" or "USD" in units. 
#' Defaults to "($ thousands)"
#' 
#' @seealso tidy_data
#' @seealso get_uk_values
#'
#' @return Dataframe - same as gbp_data but with constant USD instead of GBP
#' 
#' @examples {
#' gbp_data <- read.csv(system.file("testdata", "year_value.csv",
#' package = "SDGupdater"))
#' rates_filepath <- system.file("testdata", "Exchange-rates.xlsx", 
#' package = "SDGupdater")
#' deflators_filepath <- system.file("testdata", "Deflators-base-2020.xlsx", 
#' package = "SDGupdater")
#' gbp_to_constant_usd(rates_filepath, deflators_filepath, gbp_data)
#' }
#'
#' @export
gbp_to_constant_usd <- function(rates_filepath, deflators_filepath, gbp_data,
                                unit_multiplier = "($ thousands)") {

  exchange_rates <- read_exchange_rates(rates_filepath)
  deflators <- read_deflators(deflators_filepath)

  usd_data <- gbp_to_usd(exchange_rates, gbp_data, unit_multiplier)
  constant_usd <- usd_to_constant_usd(deflators, usd_data, unit_multiplier)
  
  return(constant_usd)
}

#' @describeIn gbp_to_constant_usd read in exchange rate xlsx file
read_exchange_rates <- function(rates_filepath) {
  tidyxl::xlsx_cells(rates_filepath)
}

#' @describeIn gbp_to_constant_usd read in deflators xlsx file
read_deflators <- function(deflators_filepath) {
  tidyxl::xlsx_cells(deflators_filepath, sheets = "Deflators")
}

#' @describeIn gbp_to_constant_usd convert GBP to (non-constant) USD
gbp_to_usd <- function(exchange_rates, gbp_data, 
                       unit_multiplier = "($ thousands)") {
  
  heading_row <- which(!is.na(exchange_rates$numeric))[1]
  exchange_data <- tidy_data(exchange_rates, heading_row)
  uk_exchange_data <- get_uk_values(exchange_data, exchange_rate)
  uk_exchange_data_check <- check_data(uk_exchange_data, 0.1, 2)
  usd_data <- apply_exchange_rate(gbp_data, uk_exchange_data, unit_multiplier)
  
  return(usd_data)
}

#' @describeIn gbp_to_constant_usd convert USD to constant USD
usd_to_constant_usd <- function(deflators, usd_data, 
                                unit_multiplier = "$ thoudands") {
  heading_row <- which(!is.na(deflators$numeric))[1]
  deflators_data <- tidy_data(deflators, heading_row)
  uk_deflators <- get_uk_values(deflators_data, deflator)
  uk_deflators_check <- check_data(uk_deflators, 9, 160)
  constant_usd_data <- apply_deflators(usd_data, uk_deflators, 
                                       unit_multiplier)
}

#' @describeIn gbp_to_constant_usd convert GBP to (non-constant) USD
check_data <- function(dat, min_expected, max_expected) {
  min_uk <- min(dat[2]) 
  max_uk <- max(dat[2]) 
  
  if (deparse(substitute(dat)) == "uk_exchange_data") {
    data_used <- "UK exchange rates"
  } else if (deparse(substitute(dat)) == "uk_deflators") {
    data_used <- "UK deflators"
  } else {
    data_used <- "data"
  }
  
  if (min_uk < min_expected) {
    warning(paste("Some", data_used, "were lower than ", min_expected, 
                  ". Please check that the ", data_used, 
                  "does not contain errors"))
  }
  
  if (max_uk > max_expected) {
    warning(paste("Some", data_used, "were hihger than ", max_expected, 
                  ". Please check that the ", data_used, 
                  "does not contain errors"))
  }
}

#' Tidy exchange rate and deflators data
#'
#' Tidies exchange rate and deflators data from 
#' <https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/>
#' so that it can be used in conversions.  
#'
#' @seealso gbp_to_constant_usd
#' @param dat Exchange rate or deflators data frame (link in description)
#' @param heading_row Numeric. The row on which headings are given in the xlsx
#'
#' @return dataframe - gbp_data with an additional column giving value as 
#' constant USD
#'
#' @export
tidy_data <- function(dat, heading_row) {
  dat %>% 
    dplyr::filter(row >= heading_row) %>% 
    unpivotr::behead("left", country) %>% 
    unpivotr::behead("up", year) %>% 
    dplyr::filter(!is.na(numeric)) %>% 
    dplyr::select(year, country, numeric)
}

#' Select UK deflator/exchange rate values 
#'
#' Selects UK exchange rate and deflators data from 
#' <https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/>
#' so that it can be used in conversions.  
#'
#' @seealso gbp_to_constant_usd
#' @param dat Exchange rate or deflators data frame (link in description)
#' @param value_name The new name of the value column
#'
#' @return dataframe - uk rows of dat
#'
#' @export
get_uk_values <- function(dat, value_name) {
  dat %>% 
    dplyr::filter(tolower(country) %in% c("uk", "united kingdom")) %>% 
    dplyr::rename(!!dplyr::enquo(value_name) := numeric) %>% 
    dplyr::select(year, !!dplyr::enquo(value_name))
}

#' @describeIn gbp_to_constant_usd apply US exchange rate to GBP
apply_exchange_rate <- function(gbp_data, uk_exchange_data, 
                                unit_multiplier = "($ thousands)") {
  names(gbp_data) <- tolower(names(gbp_data))
  names(uk_exchange_data) <- tolower(names(uk_exchange_data))
  
  gbp_data %>% 
    dplyr::left_join(uk_exchange_data, by = "year" ) %>% 
    dplyr::mutate(value = value/exchange_rate,
                  units = trimws(paste("USD", unit_multiplier))) %>% 
    dplyr::select(-exchange_rate)
}

#' @describeIn gbp_to_constant_usd apply UK deflators to USD values
apply_deflators <- function(usd_data, uk_deflators, 
                            unit_multiplier = "($ thousands)") {
  usd_data %>% 
    dplyr::left_join(uk_deflators, by = "year") %>% 
    dplyr::mutate(value = (value/deflator)*100,
           units = trimws(paste("Constant USD", unit_multiplier))) %>% 
    dplyr::select(-deflator)
}
