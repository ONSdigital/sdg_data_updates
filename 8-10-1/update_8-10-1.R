# author: Katie Uzzell
# date: 04/07/2023

# Code to automate data update for indicator 8-10-1 
# (Part (a) only - Number of commercial bank branches per 100,000 adults).

# read in data 

banks_by_country_source <- get_type1_data(banks_bs_header_row, banks_country, tabname)
banks_by_region_source <- get_type1_data(banks_bs_header_row, banks_region, tabname)
banks_by_la_source <- get_type1_data(banks_bs_header_row, banks_la, tabname)
bs_by_country_source <- get_type1_data(banks_bs_header_row, bs_country, tabname)
bs_by_region_source <- get_type1_data(banks_bs_header_row, bs_region, tabname)
bs_by_la_source <- get_type1_data(banks_bs_header_row, bs_la, tabname)
pop_ests_by_country_source <- get_type1_data(pop_ests_header_row, pop_ests_country, tabname)
pop_ests_by_region_source <- get_type1_data(pop_ests_header_row, pop_ests_region, tabname)
pop_ests_by_la_source <- get_type1_data(pop_ests_header_row, pop_ests_la, tabname)

# remove cells above column names

banks_by_country_main <- extract_data(banks_by_country_source, banks_bs_header_row)
banks_by_region_main <- extract_data(banks_by_region_source, banks_bs_header_row)
banks_by_la_main <- extract_data(banks_by_la_source, banks_bs_header_row)
bs_by_country_main <- extract_data(bs_by_country_source, banks_bs_header_row)
bs_by_region_main <- extract_data(bs_by_region_source, banks_bs_header_row)
bs_by_la_main <- extract_data(bs_by_la_source, banks_bs_header_row)
pop_ests_by_country_main <- extract_data(pop_ests_by_country_source, pop_ests_header_row)
pop_ests_by_region_main <- extract_data(pop_ests_by_region_source, pop_ests_header_row)
pop_ests_by_la_main <- extract_data(pop_ests_by_la_source, pop_ests_header_row)

# remove blank rows and rows with footnotes

banks_by_country_main <- banks_by_country_main[complete.cases(banks_by_country_main), ]
banks_by_region_main <- banks_by_region_main[complete.cases(banks_by_region_main), ]
banks_by_la_main <- banks_by_la_main[complete.cases(banks_by_la_main), ]
bs_by_country_main <- bs_by_country_main[complete.cases(bs_by_country_main), ]
bs_by_region_main <- bs_by_region_main[complete.cases(bs_by_region_main), ]
bs_by_la_main <- bs_by_la_main[complete.cases(bs_by_la_main), ]

# combine country data

banks_by_country_main <- banks_by_country_main %>% 
  pivot_longer(-c("Date"), names_to = "Country", values_to = "Banks")
bs_by_country_main <- bs_by_country_main %>% 
  pivot_longer(-c("Date"), names_to = "Country", values_to = "Building Societies")
pop_ests_by_country_main <- pop_ests_by_country_main %>% 
  pivot_longer(-c("Date"), names_to = "Country", values_to = "Population Estimate")

country_data <- full_join(banks_by_country_main, bs_by_country_main, by = c("Date", "Country"))

country_data <- full_join(country_data, pop_ests_by_country_main, by = c("Date", "Country"))

country_data <- country_data %>% 
  rename("Year" = Date)

# combine region data

banks_by_region_main <- banks_by_region_main %>% 
  pivot_longer(-c("Date"), names_to = "Region", values_to = "Banks")
bs_by_region_main <- bs_by_region_main %>% 
  pivot_longer(-c("Date"), names_to = "Region", values_to = "Building Societies")
pop_ests_by_region_main <- pop_ests_by_region_main %>% 
  pivot_longer(-c("Date"), names_to = "Region", values_to = "Population Estimate")

region_data <- full_join(banks_by_region_main, bs_by_region_main, by = c("Date", "Region"))

region_data <- full_join(region_data, pop_ests_by_region_main, by = c("Date", "Region"))

region_data <- region_data %>% 
  rename("Year" = Date)

# combine local authority data

banks_by_la_main <- banks_by_la_main %>%  
  rename("Local Authority" = "local authority: district / unitary (as of April 2021)")
bs_by_la_main <- bs_by_la_main %>%  
  rename("Local Authority" = "local authority: district / unitary (as of April 2021)")
pop_ests_by_la_main <- pop_ests_by_la_main %>%  
  rename("Local Authority" = "local authority: district / unitary (as of April 2021)")

banks_by_la_main$`2010` <- as.numeric(as.character(banks_by_la_main$`2010`))
bs_by_la_main$`2010` <- as.numeric(as.character(bs_by_la_main$`2010`))
pop_ests_by_la_main$`2010` <- as.numeric(as.character(pop_ests_by_la_main$`2010`))

banks_by_la_main <- banks_by_la_main %>% 
  pivot_longer(-c("Local Authority"), names_to = "Year", values_to = "Banks")
bs_by_la_main <- bs_by_la_main %>% 
  pivot_longer(-c("Local Authority"), names_to = "Year", values_to = "Building Societies")
pop_ests_by_la_main <- pop_ests_by_la_main %>% 
  pivot_longer(-c("Local Authority"), names_to = "Year", values_to = "Population Estimate")

la_data <- full_join(banks_by_la_main, bs_by_la_main, by = c("Local Authority", "Year"))

la_data <- full_join(la_data, pop_ests_by_la_main, by = c("Year", "Local Authority"))

la_data <- la_data %>% 
  select("Year", "Local Authority", "Banks", "Building Societies", "Population Estimate")

# do calculations

country_data$`Banks` <- as.numeric(as.character(country_data$`Banks`))
country_data$`Building Societies` <- as.numeric(as.character(country_data$`Building Societies`))
country_data$`Population Estimate` <- as.numeric(as.character(country_data$`Population Estimate`))

country_data <- country_data %>% 
  mutate("Banks and Building Societies" = `Banks` + `Building Societies`)

country_data <- country_data %>% 
  mutate("Rate" = `Banks and Building Societies` / `Population Estimate` * 100000)
  
region_data$`Banks` <- as.numeric(as.character(region_data$`Banks`))
region_data$`Building Societies` <- as.numeric(as.character(region_data$`Building Societies`))
region_data$`Population Estimate` <- as.numeric(as.character(region_data$`Population Estimate`))

region_data <- region_data %>% 
  mutate("Banks and Building Societies" = `Banks` + `Building Societies`)

region_data <- region_data %>% 
  mutate("Rate" = `Banks and Building Societies` / `Population Estimate` * 100000)

la_data <- la_data %>% 
  mutate("Banks and Building Societies" = `Banks` + `Building Societies`)

la_data <- la_data %>% 
  mutate("Rate" = `Banks and Building Societies` / `Population Estimate` * 100000)

# join data



# format data

joined_data <- joined_data %>% 
  mutate("Series" = "Number of commercial bank branches and building societies per 100,000 adults",
         "Unit measure" = "Number per 100,000 adults",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value")

csv_output <- joined_data %>%            
  select("Year", "Series", "Country", "Region", "Local Authority", "Unit measure", "Unit multiplier", "Observation status", "Value")












