#' Convert GBP to constant USD
#'
#' Uses exchange rates and deflators to convert GBP values to constant USD.
#' For exchange rate and deflator data used to convert GBP to Constant USD 
#' go to “data tables section” of 
#' https://www.oecd.org/dac/financing-sustainable-development/development-finance-data/.  
#'
#' @param exchange_rates Exchange rates dataframe - see link in description. 
#' Use “Annual Exchange Rates for DAC Donor Countries from 1960 to 2020.xls” 
#' @param deflators Deflators dataframe - see link in description.
#' Use “Deflators for Resource Flows from DAC Countries (2019=100).xls”
#' @param gbp_data Dataframe with year and value as columns 
#' (case is unimportant). Value should be GBP
#'
#' @return Dataframe - gbp_data with an additional column giving value as 
#' constant USD
#'
#' @export
gbp_to_constant_usd <- function(exchange_rates, deflators, gbp_data) {
  usd_data <- gbp_to_usd(exchange_rates, gbp_data)
  constant_usd <- usd_to_constant_usd(deflators, usd_data)
  
  return(constant_usd)
}

#' @describeIn gbp_to_constant_usd convert GBP to (non-constant) USD
gbp_to_usd <- function(exchange_rates, gbp_data) {
  
  heading_row <- which(!is.na(exchange_rates$numeric))[1]
  exchange_data <- tidy_data(exchange_rates, heading_row)
  uk_exchange_data <- get_uk_values(exchange_data, exchange_rate)
  usd_data <- apply_exchange_rate(gbp_data)
  
  return(usd_data)
}

#' @describeIn gbp_to_constant_usd convert USD to constant USD
usd_to_constant_usd <- function(deflators, usd_data) {
  heading_row <- which(!is.na(deflators$numeric))[1]
  deflators_data <- tidy_data(deflators, heading_row)
  uk_deflators <- get_uk_values(deflators_data, deflator)
  constant_usd_data <- usd_to_constant_usd(usd_data)
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
    filter(row >= heading_row) %>% 
    behead("left", country) %>% 
    behead("up", year) %>% 
    filter(!is.na(numeric)) %>% 
    select(year, country, numeric)
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
    filter(tolower(country) %in% c("uk", "united kingdom")) %>% 
    rename(!!enquo(value_name) := numeric) %>% 
    select(year, !!enquo(value_name))
}

#' @describeIn gbp_to_constant_usd apply US exchange rate to GBP
apply_exchange_rate <- function(gbp_data) {
  names(gbp_data) <- tolower(gbp_data)
  names(uk_exchange_data) <- tolower(uk_exchange_data)
  
  gbp_data %>% 
    left_join(uk_exchange_data, by = "year" ) %>% 
    mutate(value = value/exchange_rate) %>% 
    select(-exchange_rate)
}

#' @describeIn gbp_to_constant_usd apply UK deflators to USD values
usd_to_constant_usd <- function(usd_data) {
  usd_data %>% 
    left_join(uk_deflators, by = "year") %>% 
    mutate(Value = (Value/deflator)*100,
           Units = "Constant USD ($ thousands)") %>% 
    select(-deflator)
}
