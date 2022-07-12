
gbp_to_constant_usd <- function(exchange_rates, deflators, gbp_data) {
  usd_data <- gbp_to_usd(exchange_rates, gbp_data)
  constant_usd <- usd_to_constant_usd(deflators, usd_data)
  
  return(constant_usd)
}

#----

gbp_to_usd <- function(exchange_rates, gbp_data) {
  
  heading_row <- which(!is.na(exchange_rates$numeric))[1]
  exchange_data <- tidy_data(exchange_rates, heading_row)
  uk_exchange_data <- get_uk_values(exchange_data, exchange_rate)
  usd_data <- gbp_to_usd(gbp_data)
  
  return(usd_data)
}

usd_to_constant_usd <- function(deflators, usd_data) {
  heading_row <- which(!is.na(deflators$numeric))[1]
  deflators_data <- tidy_data(deflators, heading_row)
  uk_deflators <- get_uk_values(deflators_data, deflator)
  constant_usd_data <- usd_to_constant_usd(usd_data)
}

# ---

tidy_data <- function(dat, heading_row) {
  dat %>% 
    filter(row >= heading_row) %>% 
    behead("left", country) %>% 
    behead("up", year) %>% 
    filter(!is.na(numeric)) %>% 
    select(year, country, numeric)
}

get_uk_values <- function(dat, value_name) {
  dat %>% 
    filter(tolower(country) %in% c("uk", "united kingdom")) %>% 
    rename(!!enquo(value_name) := numeric) %>% 
    select(year, !!enquo(value_name))
}

gbp_to_usd <- function(gbp_data) {
  gbp_data %>% 
    left_join(uk_exchange_data, by = "year" ) %>% 
    mutate(Value = Value/exchange_rate) %>% 
    select(-exchange_rate)
}

usd_to_constant_usd <- function(usd_data) {
  usd_data %>% 
    left_join(uk_deflators, by = "year") %>% 
    mutate(Value = (Value/deflator)*100,
           Units = "Constant USD ($ thousands)") %>% 
    select(-deflator)
}
