# author: Katie Uzzell
# date: 17/08/2023

# Code to automate data update for indicator 8-8-1 (Rates of fatal and non-fatal 
# occupational injuries (excluding injuries arising from road traffic accidents)).

# read in data 

fatal_inj_headline_source <- get_type1_data(fatal_inj_header_row, fatal_inj_headline, fatal_tabname)
fatal_inj_region_source <- get_type1_data(fatal_inj_header_row, fatal_inj_region, fatal_tabname)
fatal_inj_age_sex_source <- get_type1_data(fatal_inj_header_row, fatal_inj_age_sex, fatal_tabname)
nonfatal_inj_summary_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_summary, nonfatal_tabname)
nonfatal_inj_region_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_region, nonfatal_tabname)
nonfatal_inj_age_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_age, nonfatal_tabname)
nonfatal_inj_ind_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_ind, nonfatal_tabname)
nonfatal_inj_occ_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_occ, nonfatal_tabname)


# remove cells above column names

fatal_inj_headline_main <- extract_data(fatal_inj_headline_source, fatal_inj_header_row)
fatal_inj_region_main <- extract_data(fatal_inj_region_source, fatal_inj_header_row)
fatal_inj_age_sex_main <- extract_data(fatal_inj_age_sex_source, fatal_inj_header_row)
nonfatal_inj_summary_main <- extract_data(nonfatal_inj_summary_source, nonfatal_header_row)
nonfatal_inj_region_main <- extract_data(nonfatal_inj_region_source, nonfatal_header_row)
nonfatal_inj_age_main <- extract_data(nonfatal_inj_age_source, nonfatal_header_row)
nonfatal_inj_ind_main <- extract_data(nonfatal_inj_ind_source, nonfatal_header_row)
nonfatal_inj_occ_main <- extract_data(nonfatal_inj_occ_source, nonfatal_header_row)


# fatal injuries headline

fatal_inj_headline_main <- fatal_inj_headline_main[ , grepl('Year|Industry|Rate of fatal injury per 100,000 workers', names(fatal_inj_headline_main))]

fatal_inj_headline_main <- fatal_inj_headline_main %>% 
  select(-contains("Industry classification"))

colnames(fatal_inj_headline_main) [1] <- "Year"
colnames(fatal_inj_headline_main) [2] <- "Industry sector"
colnames(fatal_inj_headline_main) [3] <- "Value"

fatal_inj_headline_main <- fatal_inj_headline_main %>% 
  filter(!Year %in% c("1974",
                      "1975",
                      "1976",
                      "1977",
                      "1978",
                      "1979",
                      "1980",
                      "1981",
                      "1982",
                      "1983",
                      "1984",
                      "1985",
                      "1986/87 ",
                      "1987/88",
                      "1988/89",
                      "1989/90",
                      "1990/91",
                      "1991/92",
                      "1992/93",
                      "1993/94",
                      "1994/95",
                      "1995/96",
                      "1996/97 ",
                      "1997/98",
                      "1998/99",
                      "1999/00",
                      "2000/01",
                      "2001/02"))

fatal_inj_headline_main$`Industry sector`[fatal_inj_headline_main$`Industry sector` == "All industries"] <- ""

# Need to figure out how to get rid of notes

# fatal injuries region

fatal_inj_region_main <- fatal_inj_region_main[ , grepl('Year|Area|Rate of fatal injury per 100,000 workers', names(fatal_inj_region_main))]

fatal_inj_region_main <- fatal_inj_region_main %>% 
  select(-contains("Area code"))

colnames(fatal_inj_region_main) [1] <- "Year"
colnames(fatal_inj_region_main) [2] <- "Region"
colnames(fatal_inj_region_main) [3] <- "Value"

fatal_inj_region_main <- fatal_inj_region_main %>% 
  filter(Region %in% c("ENGLAND AND WALES",
                      "ENGLAND",
                      "WALES",
                      "SCOTLAND",
                      "NORTH EAST",
                      "NORTH WEST",
                      "YORKSHIRE AND THE HUMBER",
                      "EAST MIDLANDS",
                      "WEST MIDLANDS",
                      "EAST",
                      "LONDON",
                      "SOUTH EAST",
                      "SOUTH WEST"))

fatal_inj_region_main <- fatal_inj_region_main %>%
  mutate(Country = case_when(
    Region == "ENGLAND AND WALES" ~ "England and Wales",
    Region == "WALES" ~ "Wales",
    Region == "SCOTLAND" ~ "Scotland",
    Region == "ENGLAND" ~ "England",
    Region == "NORTH EAST" ~ "England",
    Region == "NORTH WEST" ~ "England",
    Region == "YORKSHIRE AND THE HUMBER" ~ "England",
    Region == "EAST MIDLANDS" ~ "England",
    Region == "WEST MIDLANDS" ~ "England",
    Region == "EAST" ~ "England",
    Region == "LONDON" ~ "England",
    Region == "SOUTH EAST" ~ "England",
    Region == "SOUTH WEST" ~ "England"))


fatal_inj_region_main <- fatal_inj_region_main %>%
  mutate(Region = case_when(
    Region == "ENGLAND AND WALES" ~ "",
    Region == "WALES" ~ "",
    Region == "SCOTLAND" ~ "",
    Region == "ENGLAND" ~ "",
    Region == "NORTH EAST" ~ "North East",
    Region == "NORTH WEST" ~ "North West",
    Region == "YORKSHIRE AND THE HUMBER" ~ "Yorkshire and The Humber",
    Region == "EAST MIDLANDS" ~ "East Midlands",
    Region == "WEST MIDLANDS" ~ "West Midlands",
    Region == "EAST" ~ "East",
    Region == "LONDON" ~ "London",
    Region == "SOUTH EAST" ~ "South East",
    Region == "SOUTH WEST" ~ "South West"))

fatal_inj_region_main <- fatal_inj_region_main %>%
  select("Year", "Country", "Region", "Value")

# Need to figure out how to get rid of notes

# fatal injuries age and sex

fatal_inj_age_sex_main <- fatal_inj_age_sex_main[ , grepl('Year|Main Industry|Gender|Age|Rate of fatal injury per 100,000 workers', names(fatal_inj_age_sex_main))]

colnames(fatal_inj_age_sex_main) [1] <- "Year"
colnames(fatal_inj_age_sex_main) [2] <- "Industry sector"
colnames(fatal_inj_age_sex_main) [3] <- "Sex"
colnames(fatal_inj_age_sex_main) [4] <- "Age"
colnames(fatal_inj_age_sex_main) [5] <- "Value"

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>% 
  filter(!Age %in% c("Unknown"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main[fatal_inj_age_sex_main$`Industry sector` == "All industry", ]


fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate(Age = case_when(
    Age == "All" ~ "",
    Age == "Under 16" ~ "Under 16",
    Age == "16-19" ~ "16 to 24",
    Age == "20-24" ~ "20 to 24",
    Age == "25-34" ~ "25 to 34",
    Age == "35-44" ~ "35 to 44",
    Age == "45-54" ~ "45 to 54",
    Age == "55-59" ~ "55 to 59",
    Age == "60-64" ~ "60 to 64",
    Age == "65+" ~ "65 and over"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>% 
  filter(!Sex %in% c("Unknown"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate(Sex = case_when(
    Sex == "All" ~ "",
    Sex == "Male" ~ "Male",
    Sex == "Female" ~ "Female"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate("Industry sector" = "")

# Need to remove rows with all blank disaggs

# Need to figure out how to get rid of notes

# Then join fatal data


# Non-fatal data








# OLD CODE IN CASE ITS USFEUL WHILE I WRITE


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


