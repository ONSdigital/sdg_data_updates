data_17191 <- oda_renamed %>% 
  filter(sector_purpose_code == crs_code_17191) %>% 
  group_by(year, country_income_classification) %>% 
  summarise(value = sum(net_oda, na.rm = TRUE))

headline <- data_17191 %>% 
  group_by(year) %>% 
  summarise(value = sum(value))

gbp_data <- bind_rows(data_17191, 
                      headline) %>% 
  mutate(Units = "GBP (thousands)",
         country_income_classification = ifelse(
           grepl("unallocated", country_income_classification)== TRUE |
             country_income_classification == "0",
           "Unspecified", country_income_classification)
  )

#constant_usd_data <-  gbp_to_constant_usd(rates_filepath, deflators_filepath, 
#                                          gbp_data)
read_exchange_rates <- function(rates_filepath) {
  tidyxl::xlsx_cells(rates_filepath)
}

tidy_data <- function(dat, heading_row) {
  dat %>% 
    dplyr::filter(row >= heading_row) %>% 
    unpivotr::behead("left", country) %>% 
    unpivotr::behead("up", year) %>% 
    dplyr::filter(!is.na(numeric)) %>% 
    dplyr::select(year, country, numeric)
}

apply_exchange_rate <- function(gbp_data, uk_exchange_data) {
  names(gbp_data) <- tolower(names(gbp_data))
  names(uk_exchange_data) <- tolower(names(uk_exchange_data))
  
  gbp_data %>% 
    dplyr::left_join(uk_exchange_data, by = "year" ) %>% 
    dplyr::mutate(value = value/exchange_rate,
                  units = "USD (thousands)") %>% 
    dplyr::select(-exchange_rate)
}

gbp_to_usd <- function(exchange_rates, gbp_data) {
  
  heading_row <- which(!is.na(exchange_rates$numeric))[1]
  exchange_data <- tidy_data(exchange_rates, heading_row)
  uk_exchange_data <- get_uk_values(exchange_data, exchange_rate)
  usd_data <- apply_exchange_rate(gbp_data, uk_exchange_data)
  
  return(usd_data)
}
exchange_rates <- read_exchange_rates(rates_filepath)
usd_data <- gbp_to_usd(exchange_rates, gbp_data)
names(gbp_data) <- str_to_sentence(names(gbp_data))
#names(constant_usd_data) <- str_to_sentence(names(constant_usd_data))
names(usd_data) <- str_to_sentence(names(usd_data))
csv <- gbp_data %>% 
  bind_rows(usd_data) %>% 
  mutate(Series = "Value of all resources made available to strengthen statistical capacity in developing countries",
         `Observation status` = "Normal value", `Unit multiplier` = "Thousands") %>% 
  select(Year, Series, Country_income_classification,
         `Observation status`,`Unit multiplier`, Units, Value) %>% 
  arrange(Year, Country_income_classification) %>% 
  replace(is.na(.), "") %>% 
  rename(`Country income classification` = Country_income_classification)

rm(data_17191, headline,
   gbp_data, usd_data)

scripts_run <- c(scripts_run, "17-19-1")