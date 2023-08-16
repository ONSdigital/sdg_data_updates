# author: Katie Gummer
# date: 14/08/2023

# Code to automate data update for indicator 17-10-1 (Energy intensity measured in terms of primary energy and GDP)

#### read in data ####

main_data <- get_type1_data(header_row, source_data, tabname)

#### select the necessary columns ####
trade_data <- main_data %>% 
  select("TimePeriod", "SeriesCode", "Type.of.product", "Value")

#### renaming columns ####
trade_data <- trade_data %>%
  rename("Year" = "TimePeriod", 
         "Series" = "SeriesCode", 
         "Type of product" = "Type.of.product")

#### correcting data ####
trade_data$Series[trade_data$Series == 'TM_TAX_WMFN'] <- 'Most favoured nation status'

trade_data$Series[trade_data$Series == 'TM_TAX_WMPS'] <- 'Preferential status'

trade_data$`Type of product`[trade_data$`Type of product` == 'ARM'] <- 'Arms'
trade_data$`Type of product`[trade_data$`Type of product` == 'AGR'] <- 'Agricultural products'
trade_data$`Type of product`[trade_data$`Type of product` == 'ALP'] <- 'Total or no breakdown'
trade_data$`Type of product`[trade_data$`Type of product` == 'TEX'] <- 'Textiles'
trade_data$`Type of product`[trade_data$`Type of product` == 'OIL'] <- 'Oil'
trade_data$`Type of product`[trade_data$`Type of product` == 'IND'] <- 'Industrial products'
trade_data$`Type of product`[trade_data$`Type of product` == 'CLO'] <- 'Clothing'



#### Format csv ####

csv_formatted <- trade_data %>% 
         mutate("Units" = "Percentage (%)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value")



csv_output <- csv_formatted %>%            
select("Year", "Series", "Type of product", "Units", "Unit multiplier", "Observation status", "Value")







