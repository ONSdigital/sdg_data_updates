# Authors: Emmma Wood, Varun Jakki
# Purpose: Get data from the APS dataset for the following disaggregations:
#             sex, sector (agriculture/non-agriculture), and sector by sex 
# Requires: Access to the LFS_SPSS drive.
#           This file is called by compile_tables.R, and requires config.R 

# About this code: This code creates a CSV for indicator 8.3.1 - The calculations completed are: 
# Proportion of informal employment in total employment = (Informal employment/Total employment) × 100
# Proportion of informal employment in agriculture = (Informal employment in agricultural activities/Total employment in agriculture) × 100
# Proportion of informal employment in non agricultural employment = (Informal employment in non agricultural activities/Total employment in non agricultural activities) × 100

# Code last updated: 27/03/2021

###############
check_for_caseno_repeats <- function(dat) {
  dat %>%
    group_by(CASENO) %>%
    summarise(caseno_count = n(), .groups = 'drop') %>%
    filter(caseno_count > 1)
}

count_respondents <- function(dat, group_var){
  
  dat %>% 
    group_by(across(all_of(group_var))) %>% 
    summarise(count = n(), .groups = 'drop')

}

sum_weights <- function(dat, group_var, new_col) {
  
  new_col <- enquo(new_col)
  new_col_name <- quo_name(new_col)
  
  dat %>% 
    group_by(across(all_of(group_var))) %>% 
    summarise(!!new_col_name := sum(weight), .groups = 'drop') 
}

not_all_na <- function(x) {any(!is.na(x))}

##########

APS_data <- read_sav(input)

colnames(APS_data) <- toupper(colnames(APS_data)) # column name case varies from year to year

employed <- APS_data %>% 
  select(INECAC05, INDS07M, SEX, PWTA18, CASENO, GOR9D, CTRY9D) %>% 
  rename(industry = INDS07M,
         employment_status = INECAC05,
         weight = PWTA18,
         GeoCode = GOR9D,
         Country = CTRY9D) %>% 
  mutate(Sector = ifelse(industry == 1, "Agriculture", "Non-Agriculture")) %>% 
  filter(!is.na(Sector)) %>%  # removes anyone without an industry e.g. inactive people
  filter(employment_status %in% c(1:4))   # 1 = employed, 2 = self employed, 3 = Government schemes, 4 = unpaid family workers


# Year-specific edits ----

unique(employed$Country)
# Northern Ireland is -9 for Country in 2014
unique(employed$GeoCode)
# Northern Ireland isn't entered as a GeoCode in 2014

if(year == "2014") {
  employed <- employed %>% 
    mutate(Country = ifelse(Country == "-9", "N92000002", as.character(Country))) %>% 
    mutate(GeoCode = ifelse(Country == "N92000002", "N99999999", as.character(GeoCode)))
}

############################

unpaid_family_workers  <- employed %>% 
  filter(employment_status  == 4) # 4 refers to unpaid family workers


# get denominators ----
total_employed_by_sex <- sum_weights(employed, "SEX", Total_employment)
total_employed_by_country <-  sum_weights(employed, "Country", Total_employment)
total_employed_by_region <-  sum_weights(employed, "GeoCode", Total_employment)
total_employed_by_sector <- sum_weights(employed, "Sector", Total_employment)

total_employed_by_sector_by_sex <- sum_weights(employed, c("Sector", "SEX"), Total_employment)
total_employed_by_country_by_sex <- sum_weights(employed, c("Country", "SEX"), Total_employment)

total_employed_by_country_by_sector <-  sum_weights(employed, c("Country", "Sector"), Total_employment)
total_employed_by_region_by_sector <-  sum_weights(employed, c("GeoCode", "Sector"), Total_employment)

regional_employed_totals <- bind_rows(total_employed_by_country, total_employed_by_region, 
                                        total_employed_by_country_by_sex, 
                                        total_employed_by_country_by_sector, total_employed_by_region_by_sector) %>% 
  filter(!GeoCode %in% c("N99999999", "S99999999", "W99999999")) %>%  
  mutate(GeoCode = coalesce(GeoCode, Country)) %>% 
  select(-Country)

denominators <- bind_rows(total_employed_by_sex, total_employed_by_sector, total_employed_by_sector_by_sex, regional_employed_totals)

# get numerators ----
informal_employed_by_sex <- sum_weights(unpaid_family_workers, "SEX", informal_employment) 
informal_employed_by_country <- sum_weights(unpaid_family_workers, "Country", informal_employment)
informal_employed_by_region <- sum_weights(unpaid_family_workers, "GeoCode", informal_employment)
informal_employed_by_sector <- sum_weights(unpaid_family_workers, "Sector", informal_employment)

informal_employed_by_sector_by_sex <- sum_weights(unpaid_family_workers, c("Sector", "SEX"), informal_employment) 
informal_employed_by_country_by_sex <- sum_weights(unpaid_family_workers, c("Country", "SEX"), informal_employment)

informal_employed_by_country_by_sector <- sum_weights(unpaid_family_workers, c("Country", "Sector"), informal_employment)
informal_employed_by_region_by_sector <- sum_weights(unpaid_family_workers, c("GeoCode", "Sector"), informal_employment)

regional_unpaid_family_workers_totals <- bind_rows(informal_employed_by_country, informal_employed_by_region, 
                                                   informal_employed_by_country_by_sex, 
                                                   informal_employed_by_country_by_sector, informal_employed_by_region_by_sector) %>% 
  filter(!GeoCode %in% c("N99999999", "S99999999", "W99999999")) %>% 
  mutate(GeoCode = coalesce(GeoCode, Country)) %>% 
  select(-Country)

numerators <- bind_rows(informal_employed_by_sex, informal_employed_by_sector, informal_employed_by_sector_by_sex, regional_unpaid_family_workers_totals)

# Join data and do calculations ----
disaggregation_data_for_calculations <- denominators %>% 
  left_join(numerators, by = c("SEX", "Sector", "GeoCode")) 

headline_data_for_calculations <- disaggregation_data_for_calculations %>% 
  filter(is.na(GeoCode) & is.na(SEX)) %>% 
  summarise(Total_employment = sum(Total_employment),
            informal_employment = sum(informal_employment), .groups = 'drop')

all_data <- bind_rows(headline_data_for_calculations, disaggregation_data_for_calculations) %>% 
  mutate(Value = (informal_employment/Total_employment)*100)

# count number of respondents for main employment ------

sector_counts_all_employed <- count_respondents(employed, c("Sector"))
sex_counts_all_employed <- count_respondents(employed, "SEX")
sex_by_sector_counts_all_employed <- count_respondents(employed, c("Sector", "SEX"))

region_counts_all_employed <- count_respondents(employed, "GeoCode")
region_by_sector_counts_all_employed <- count_respondents(employed, c("GeoCode", "Sector"))

country_counts_all_employed <- count_respondents(employed, "Country")
country_by_sector_counts_all_employed <- count_respondents(employed, c("Country", "Sector"))
country_by_sex_counts_all_employed <- count_respondents(employed, c("Country", "SEX"))

total_count_employed <- summarise(employed, count = n())

all_counts_employed <- bind_rows(sex_counts_all_employed, country_counts_all_employed,
                                   region_counts_all_employed, sector_counts_all_employed,
                                   sex_by_sector_counts_all_employed, country_by_sex_counts_all_employed,
                                   country_by_sector_counts_all_employed,region_by_sector_counts_all_employed,
                                   total_count_employed) %>% 
  filter(!GeoCode %in% c("N99999999", "S99999999", "W99999999")) 

employment_counts_one_geography <- all_counts_employed %>%
  mutate(GeoCode = coalesce(GeoCode, Country)) %>%
  rename(`Number of respondents for people in employment` = count) %>% 
  select(-Country)

# Count number of respondents for informal employment-----

sector_counts_informal <- count_respondents(unpaid_family_workers, "Sector")
sex_counts_informal <- count_respondents(unpaid_family_workers, "SEX")
sex_by_sector_counts_informal <- count_respondents(unpaid_family_workers, c("SEX", "Sector"))

region_counts_informal <- count_respondents(unpaid_family_workers, "GeoCode")
region_by_sector_counts_informal <- count_respondents(unpaid_family_workers, c("GeoCode", "Sector"))

country_counts_informal <- count_respondents(unpaid_family_workers, "Country")
country_by_sector_counts_informal <- count_respondents(unpaid_family_workers, c("Country", "Sector"))
country_by_sex_counts_informal <- count_respondents(unpaid_family_workers, c("Country", "SEX"))

total_count_informal <- summarise(unpaid_family_workers, count = n())

all_counts_informal <- bind_rows(sector_counts_informal, sex_counts_informal, sex_by_sector_counts_informal,
                        region_counts_informal, region_by_sector_counts_informal,
                        country_counts_informal, country_by_sector_counts_informal, country_by_sex_counts_informal,
                        total_count_informal) %>% 
  filter(!GeoCode %in% c("N99999999", "S99999999", "W99999999")) 

informal_counts_one_geography <- all_counts_informal %>% 
  mutate(GeoCode = coalesce(GeoCode, Country)) %>%
  select(-Country)

# add count information and suppress low counts
quality_control <- all_data %>% 
  left_join(informal_counts_one_geography, by = c("SEX", "Sector", "GeoCode")) %>% 
  rename(`Number of respondents informal employment` = count) %>% 
  mutate(`Number of respondents informal employment` = ifelse(`Number of respondents informal employment` < 3, 
                                          "suppressed", as.character(`Number of respondents informal employment`)),
         Value = ifelse(`Number of respondents informal employment` == "suppressed", NA, Value),
         informal_employment = ifelse(`Number of respondents informal employment` == "suppressed", NA, informal_employment)) %>% 
  left_join(employment_counts_one_geography, by = c("SEX", "Sector", "GeoCode")) %>%
  mutate(`Number of respondents for people in employment` = ifelse(`Number of respondents for people in employment` < 3, 
                                          "suppressed", as.character(`Number of respondents for people in employment`)),
         Total_employment = ifelse(`Number of respondents for people in employment` == "suppressed", NA, Total_employment))

# create final tables ----

for_publication_and_csv <- quality_control %>%
  mutate(Year = year, # year is defined in compile_tables
         Sector = ifelse(is.na(Sector), "", Sector),
         GeoCode = ifelse(is.na(GeoCode), "", GeoCode),
         Value = ifelse(is.na(Value), "", as.character(Value)),
         Sex = case_when(
           SEX == 1 ~ "Male",
           SEX == 2 ~ "Female",
           is.na(SEX) ~ ""),
         Region = case_when(
           GeoCode == "E12000001" ~ "North East",
           GeoCode == "E12000002" ~ "North West",
           GeoCode == "E12000003" ~ "Yorkshire and The Humber",
           GeoCode == "E12000004" ~ "East Midlands",
           GeoCode == "E12000005" ~ "West Midlands",
           GeoCode == "E12000006" ~ "East",
           GeoCode == "E12000007" ~ "London",
           GeoCode == "E12000008" ~ "South East",
           GeoCode == "E12000009" ~ "South West",
           TRUE ~ ""), # In a case_when this final "TRUE" translates as "all other cases"
         Country = case_when(
           GeoCode == "W92000004" ~ "Wales",
           GeoCode == "S92000003" ~ "Scotland",
           GeoCode == "N92000002" ~ "Northern Ireland",
           GeoCode == "E92000001" ~ "England",
           TRUE ~ "")) %>% 
  select(-SEX)

# final table for current year for indicator csv ----
csv <- for_publication_and_csv %>%
  filter(Value != "") %>% 
  mutate(`Unit measure` = "Percentage (%)",
         `Unit multiplier`= "Units",
         `Observation status`= "Undefined") %>%
  select(Year,Country, Region, Sex, Sector, 
         `Observation status`, `Unit multiplier`, `Unit measure`, GeoCode, Value)

# publication ----
publication_data <- for_publication_and_csv %>%
  mutate(Country = ifelse(Country == "" & Region == "", "United Kingdom", Country),
         Country = ifelse(Region != "", "England", Country),
         GeoCode = ifelse(Country == "United Kingdom", "K02000001", GeoCode),
         Sex = ifelse(Sex == "", "Total", as.character(Sex)),
         Sex = ifelse(Sex == "Male", "Men", as.character(Sex)),
         Sex = ifelse(Sex == "Female", "Women", as.character(Sex)),
         Sector = ifelse(Sector == "", "Total", Sector),
         `Number of people in informal employment` = ifelse(is.na(informal_employment), "-", informal_employment),
         `Number of people in employment` = ifelse(is.na(Total_employment), "-", Total_employment),
         `Percentage of employed people in informal employment` = ifelse(Value == "" | is.na(Value), "-", Value)) %>% 
  select(Year, Sector, Country, Region, Sex, GeoCode, 
         `Number of people in employment`, `Number of people in informal employment`, `Percentage of employed people in informal employment`, 
         `Number of respondents informal employment`, `Number of respondents for people in employment`)

# final tables for ad-hoc 
sector_by_sex <- publication_data %>%
  filter(Country == "United Kingdom") %>% 
  mutate(Sex_order = case_when(
    Sex == "Men" ~ 1,
    Sex == "Women" ~ 2,
    Sex == "Total" ~ 3)) %>% 
  arrange(Sector, Sex_order) %>% 
  select(-c(Country, Region, GeoCode, Sex_order))

sector_by_region <- publication_data %>%
  filter(Sex == "Total" & Region != "") %>% 
  arrange(Sector, GeoCode) %>% 
  select(-c(Sex, Country))

sector_by_country <- publication_data %>%
  filter(Region == "" & Sex == "Total") %>% 
  mutate(Country_order = case_when(
           Country == "England" ~ 1,
           Country == "Northern Ireland" ~ 2,
           Country == "Scotland" ~ 3,
           Country == "Wales" ~ 4,
           Country == "United Kingdom" ~ 5)) %>% 
  arrange(Sector, Country_order) %>% 
  select(-c(Region, Sex, Country_order))

country_by_sex <- publication_data %>%
  filter(Region == "" & Sector == "Total") %>% 
  mutate(Country_order = case_when(
    Country == "England" ~ 1,
    Country == "Northern Ireland" ~ 2,
    Country == "Scotland" ~ 3,
    Country == "Wales" ~ 4,
    Country == "United Kingdom" ~ 5),
    Sex_order = case_when(
      Sex == "Men" ~ 1,
      Sex == "Women" ~ 2,
      Sex == "Total" ~ 3)) %>% 
  arrange(Country_order, Sex_order) %>% 
  select(-c(Region, Country_order, Sector, Sex_order))


#### Checks

repeat_check_employed <- check_for_caseno_repeats(employed)
repeat_check_unpaid <- check_for_caseno_repeats(unpaid_family_workers)

low_counts <- all_counts_informal %>% 
  filter(count <= 25) %>% 
  select_if(not_all_na)

disaggregations_with_low_counts <- low_counts %>% 
  select(-count) %>% 
  mutate(SEX = ifelse(is.na(SEX), "0", "Sex")) %>%
  mutate(Sector = ifelse(is.na(Sector), "0", "Sector")) %>%
  mutate(GeoCode = ifelse(is.na(GeoCode), "0", "Region")) %>%
  mutate(Country = ifelse(is.na(Country), "0", "Country")) %>% 
  mutate(disaggregation = paste(Country, "by", GeoCode, "by", Sector, "by", SEX)) %>% 
  mutate(disaggregation = gsub("0 by ", "", disaggregation)) %>% 
  mutate(disaggregation = gsub(" by 0", "", disaggregation)) %>% 
  distinct() %>% 
  select(disaggregation) %>% 
  mutate(year = substr(year_filepath, 1, 4))

# suppressed_data <- quality_control %>% 
#   filter(`Number of respondents informal employment`, `Number of respondents for people in employment` == "suppressed") %>%
#   mutate(Year = substr(year_filepath, 1, 4)) %>% 
#   select_if(not_all_na) %>% 
#   select(-`Number of respondents`)



