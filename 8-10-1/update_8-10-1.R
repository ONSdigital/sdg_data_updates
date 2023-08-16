# author: Katie Uzzell
# date: 10/08/2023

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

joined_data <- full_join(country_data, region_data, by = c("Year", 
                                                           "Banks", 
                                                           "Building Societies", 
                                                           "Population Estimate",
                                                           "Banks and Building Societies",
                                                           "Rate"))

joined_data <- full_join(joined_data, la_data, by = c("Year", 
                                                           "Banks", 
                                                           "Building Societies", 
                                                           "Population Estimate",
                                                           "Banks and Building Societies",
                                                           "Rate"))

joined_data <- joined_data %>% 
  select("Year", "Country", "Region", "Local Authority", "Rate")

joined_data <- joined_data %>% drop_na("Rate")

# format data

joined_data <- joined_data %>% 
  rename("Value" = "Rate")

joined_data <- joined_data %>% 
  mutate("Series" = "(a) Number of commercial bank branches and building societies per 100,000 adults",
         "Units" = "Number per 100,000 adults",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value")

joined_data["Country"][joined_data["Country"] == 'United Kingdom'] <- ''

joined_data <- joined_data %>% 
  replace(is.na(.), "")

joined_data <- joined_data %>%            
  select("Year", "Series", "Country", "Region", "Local Authority", "Units", "Unit multiplier", "Observation status", "Value")

setwd(input_folder)

la_lookup <- read.csv(la_lookup)

setwd("..")

colnames(la_lookup)[2] <- "Local Authority"
colnames(la_lookup)[4] <- "Region"

la_lookup <- la_lookup %>% 
  select("Local Authority", "Region")

joined_data <- joined_data %>%
  left_join(la_lookup, by = 'Local Authority')

joined_data <- joined_data %>%
  replace(is.na(.), "")

joined_data$Region <- paste(joined_data$Region.x, joined_data$Region.y, sep="")

joined_data <- joined_data %>%            
  select("Year", "Series", "Country", "Region", "Local Authority", "Units", "Unit multiplier", "Observation status", "Value")

joined_data <- joined_data %>% 
  mutate(Country.x = case_when(
    (`Region` %in% c("East", "East Midlands", "London", "North East", "North West", 
                     "South East", "South West", "West Midlands", "Yorkshire and The Humber")) ~ "England",
    (`Local Authority` %in% c("Blaenau Gwent", "Bridgend", "Caerphilly", "Cardiff", 
                              "Carmarthenshire", "Ceredigion", "Conwy", "Denbighshire", 
                              "Flintshire", "Gwynedd", "Isle of Anglesey", "Merthyr Tydfil", 
                              "Monmouthshire", "Neath Port Talbot", "Newport", "Pembrokeshire", 
                              "Powys", "Rhondda Cynon Taff", "Swansea", "Torfaen", 
                              "Vale of Glamorgan", "Wrexham")) ~ "Wales",
    (`Local Authority` %in% c("Aberdeen City", "Aberdeenshire", "Angus", "Argyll and Bute", 
                              "City of Edinburgh", "Clackmannanshire", "Dumfries and Galloway", 
                              "Dundee City", "East Ayrshire", "East Dunbartonshire", 
                              "East Lothian", "East Renfrewshire", "Falkirk", "Fife", 
                              "Glasgow City", "Highland", "Inverclyde", "Midlothian", "Moray", 
                              "Na h-Eileanan Siar", "North Ayrshire", "North Lanarkshire", 
                              "Orkney Islands", "Perth and Kinross", "Renfrewshire", 
                              "Scottish Borders", "Shetland Islands", "South Ayrshire", 
                              "South Lanarkshire", "Stirling", "West Dunbartonshire", 
                              "West Lothian")) ~ "Scotland",
    (`Local Authority` %in% c("Antrim and Newtownabbey", "Ards and North Down", 
                              "Armagh City, Banbridge and Craigavon", "Belfast", 
                              "Causeway Coast and Glens", "Derry City and Strabane", 
                              "Fermanagh and Omagh", "Lisburn and Castlereagh", 
                              "Mid and East Antrim", "Mid Ulster", "Newry, Mourne and Down")) ~ "Northern Ireland",
    TRUE ~ ""))

joined_data$Country2 <- paste(joined_data$Country, joined_data$Country.x, sep="")

csv_output <- joined_data %>%            
  select("Year", "Series", "Country2", "Region", "Local Authority", "Units", "Unit multiplier", "Observation status", "Value")

csv_output <- csv_output %>%
  rename("Country" = "Country2")

csv_output$Region[csv_output$Region == "East of England"] <- "East"









