# Data we need:
# 1. Number of disaster deaths by year disaggregated by
# 1.1 Country
# 1.2 Gender
# 1.3 Disaster type
# 2. Age-standardised mortality rates per 100,000 population disaggregated by
# 2.1 Country
# 2.2 Gender
# 2.3 Disaster type

# Need a table with the columns:
# YEAR, SERIES (ndeaths or mort rate), COUNTRY, SEX, CAUSE OF DEATH (words), OBSERVATION STATUS, UNIT MULTIPLIER, UNIT MEASUREMENT, GeoCODE, VALUE

# download and read in data ----------------------------------------------------
nomis_deaths <- read.csv(nomis_disaster_deaths_link) %>% # RENAME THESE
  mutate(across(where(is.factor), as.character)) %>% # are these needed?
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

nomis_mortality <- read.csv(nomis_mortality_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

ons_disaster_deaths <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons_disaster_deaths_tab, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

# Clean up ons_disaster_deaths

codes = c("X30","X31","X32","X33","X34","X35","X36","X37","X38","X39")
desc = c("Exposure to excessive natural heat",
         "Exposure to excessive natural cold",
         "Exposure to sunlight",
         "Victim of lightning",
         "Victim of earthquake",
         "Victim of volcanic eruption",
         "Victim of avalanche, landslide and other earth movements",
         "Victim of cataclysmic storm",
         "Victim of flood",
         "Exposure to other and unspecified forces of nature")

code_to_desc = data.frame(codes, desc)

recode_disaster <- function(codeValue){
  val <- desc[which(codes==codeValue)]
  return(val)
}

get_GeoCode <- function(countryName){
  if(countryName=="England") {return("E92000001")}
  else if(countryName=="Wales") {return("W92000004")}
  else {return("")}
}


# This is for ons_deaths2
get_sex_aggregates_v2 <- function(df){
  combinations <- unique(df[c("Country", "Year")])
  placeholder <- vector("integer", nrow(combinations))
  for(i in 1:nrow(combinations)){
    cty<-combinations[i,]$Country 
    yr<-combinations[i,]$Year
    toAggregate <- df %>% filter(Country==cty, Year==yr) %>% select(Value) 
    placeholder[i] <- colSums(toAggregate)
  }
  combinations <- combinations %>% 
    mutate(Value = placeholder)
  return(combinations)
}

# This is for ons_deaths4
get_sex_aggregates_v4 <- function(df){
  combinations <- unique(df[c("Country", "Year", "Cause of death")])
  placeholder <- vector("integer", nrow(combinations))
  for(i in 1:nrow(combinations)){
    cty<-combinations[i,]$Country 
    yr<-combinations[i,]$Year 
    cod<-combinations[i,]$`Cause of death`
    toAggregate <- df %>% filter(Country==cty, Year==yr, `Cause of death`==cod) %>% select(Value)
    placeholder[i] <- colSums(toAggregate)
  }
  combinations <- combinations %>% 
    mutate(Value = placeholder)
  return(combinations)
}

### Load the 4 ons tabs

ons_deaths1 <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons1, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

ons_deaths2 <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons2, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

ons_deaths3 <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons3, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

ons_deaths4 <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons4, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

###
### Clean up the ons_deaths tables
# ons_deaths1 is all COD all sex (no MALE AND FEMALE)
header_ons_1 <- which(ons_deaths1$X1 == "Country")
names(ons_deaths1) <- ons_deaths1[header_ons_1,]
ons_deaths1 <- ons_deaths1 %>% 
  tail(-header_ons_1)

ons_deaths1 <- ons_deaths1 %>% 
  select(Country, `Registration year`, Deaths) %>% 
  tidyr::fill(c('Country')) %>% 
  rename(c(Year=`Registration year`, Value=Deaths)) %>% 
  mutate(Value = as.numeric(Value)) %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(Sex = "") %>% 
  mutate(Country = ifelse(Country=="England and wales", "", Country)) %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Units = "Number") %>% 
  mutate(`Unit multiplier` = "") %>% 
  mutate(`Cause of death` = "") %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

# ons_deaths2 is all COD. Need to add rows for the sex aggregates
header_ons_2 <- which(ons_deaths2$X1 == "Country")
names(ons_deaths2) <- ons_deaths2[header_ons_2,]
ons_deaths2 <- ons_deaths2 %>% 
  tail(-header_ons_2)

ons_deaths2 <- ons_deaths2 %>% 
  select(Country, Sex, `Registration year`, Deaths) %>% 
  tidyr::fill(c('Country', 'Sex')) %>% 
  rename(c(Year=`Registration year`, Value=Deaths)) %>% 
  mutate(Value = as.numeric(Value)) %>% 
  mutate(Country = ifelse(Country=="England and wales", "", Country)) %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Units = "Number") %>% 
  mutate(`Unit multiplier` = "") %>% 
  mutate(`Cause of death` = "") %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

## Now we need to add rows for the aggregates of Sex which aren't
## present in the source data

ons_death2_sex_agg <- get_sex_aggregates_v2(ons_deaths2)

ons_death2_sex_agg <- ons_death2_sex_agg %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Sex = "") %>% 
  mutate(Units = "Number") %>% 
  mutate(`Unit multiplier` = "") %>% 
  mutate(`Cause of death` = "") %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)


###
### ons_deaths: Deaths by COD, year and country, aggregated by Sex
header_ons_3 <- which(ons_deaths3$X1 == "Country")
names(ons_deaths3) <- ons_deaths3[header_ons_3,]
ons_deaths3 <- ons_deaths3 %>% 
  tail(-header_ons_3)

# Find the columns with COD codes e.g. X32
cause_of_death_bool <- grepl("^[X][0-9][0-9]$", names(ons_deaths3))
cause_of_death_names <- names(ons_deaths3)[cause_of_death_bool]

ons_deaths3 <- ons_deaths3 %>% 
  select('Country','Year', cause_of_death_names) %>% 
  tidyr::fill(c('Country')) %>% 
  tidyr::pivot_longer(cols=cause_of_death_names, names_to="Cause of death", values_to = "Value") %>% 
  mutate(Value = as.numeric(Value)) %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>%
  mutate(Sex = "") %>% 
  mutate(`Cause of death` = lapply(`Cause of death`, recode_disaster)) %>% 
  mutate(`Unit multiplier` = "") %>%  # Blank column, multiplier is zero
  mutate(Units = "Number") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Country = ifelse(Country=="England and wales", "", Country)) %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, Units, GeoCode, Value) %>% 
  mutate(Year = as.integer(Year)) %>%  #%>% # so we can keep only <2013
  mutate(Value = as.numeric(Value)) %>% 
  mutate(`Cause of death` = unlist(`Cause of death`)) # unlist or as.character?  
  
###
### ons_deaths4 is deaths by COD by country by sex by year. 
header_ons_4 <- which(ons_deaths4$X1 == "Country")
names(ons_deaths4) <- ons_deaths4[header_ons_4,]
ons_deaths4 <- ons_deaths4 %>% 
  tail(-header_ons_4)

# Find the columns with COD codes e.g. X32
cause_of_death_bool <- grepl("^[X][0-9][0-9]$", names(ons_deaths4))
cause_of_death_names <- names(ons_deaths4)[cause_of_death_bool]

ons_deaths4 <- ons_deaths4 %>% 
  select('Country','Sex','Year', cause_of_death_names) %>% 
  tidyr::fill(c('Country', 'Sex')) %>% 
  tidyr::pivot_longer(cols=cause_of_death_names, names_to="Cause of death", values_to = "Value") %>% 
  mutate(Value = as.numeric(Value)) %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>%
  mutate(`Cause of death` = lapply(`Cause of death`, recode_disaster)) %>% 
  mutate(`Unit multiplier` = "") %>%  # Blank column, multiplier is zero
  mutate(Units = "Number") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Country = ifelse(Country=="England and wales", "", Country)) %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, Units, GeoCode, Value) %>% 
  mutate(Year = as.integer(Year)) %>%  #%>% # so we can keep only <2013
  mutate(Value = as.numeric(Value)) %>% 
  mutate(`Cause of death` = unlist(`Cause of death`)) # unlist or as.character?  

### Now to calculate the values aggregated by sex
ons_death4_sex_agg <- get_sex_aggregates_v4(ons_deaths4)

ons_death4_sex_agg <- ons_death4_sex_agg %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(Sex = "") %>% 
  mutate(Units = "Number") %>% 
  mutate(`Unit multiplier` = "") %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)



### 

# ###
# header_row_ons_disaster_deaths <- which(ons_disaster_deaths$X1 == "Country")
# ons_disaster_deaths_with_headers <- ons_disaster_deaths
# names(ons_disaster_deaths) <- ons_disaster_deaths_with_headers[header_row_ons_disaster_deaths,]
# ons_disaster_deaths <- ons_disaster_deaths %>% 
#   tail(-header_row_ons_disaster_deaths) # Remove the rows above the header
# 
# cause_of_death_bool <- grepl("^[X][0-9][0-9]$", names(ons_disaster_deaths))
# cause_of_death_names <- names(ons_disaster_deaths)[cause_of_death_bool]
# ons_disaster_deaths <- ons_disaster_deaths %>%
#   select('Country', 'Sex', 'Year', cause_of_death_names) %>% 
#   tidyr::fill(c('Country', 'Sex')) %>% 
#   #dplyr::rename(codes, desc)
#   tidyr::pivot_longer(cols=cause_of_death_names, names_to="Cause of death", values_to = "Value") %>% 
#   mutate(Series = "Number of deaths from exposure to forces of nature") %>%
#   mutate(`Cause of death` = lapply(`Cause of death`, recode_disaster)) %>% 
#   mutate(`Unit multiplier` = "") %>%  # Blank column, multiplier is zero
#   mutate(Units = "Number") %>% 
#   mutate(`Observation status` = "Normal value") %>% 
#   mutate(Country = ifelse(Country=="England and wales", "", Country)) %>% 
#   mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
#   mutate(GeoCode = as.character(GeoCode)) %>% 
#   select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, Units, GeoCode, Value) %>% 
#   mutate(Year = as.integer(Year)) %>%  #%>% # so we can keep only <2013
#   mutate(Value = as.numeric(Value)) %>% 
#   mutate(`Cause of death` = unlist(`Cause of death`))
# 
# # ONS data does give aggregates for Sex, which we need so 
# ons_disaster_deaths_sex_agg <- get_sex_aggregates(ons_disaster_deaths)
# # Row bind this to the previous set
# ons_disaster_deaths_final <- rbind(ons_disaster_deaths, ons_disaster_deaths_sex_agg)
#   
# # Nomis data will be used from 2013 onwards to discard all rows >=2013
# ons_disaster_deaths_final <- ons_disaster_deaths_final[ons_disaster_deaths_final$Year<2013, ] # 

# Now to clean up the nomis death numbers
#nomis_deaths <- nomis_deaths %>%
  # Keep only rows where cause of death is an X code
  #filter(grepl("^[X][0-9][0-9]$", CAUSE_OF_DEATH_NAME) %>% 
  #mutate(`Unit multiplier` = "") %>%  # Blank column, multiplier is zero
  #mutate(Units = "Number") %>% 
  # For some reason it does not like it when I tried to add Series here
  #mutate(Series = "Number of deaths from exposure to forces of nature") %>%
  #mutate(`Observation status` = "Normal value") %>%
  #mutate(GeoCode = "") # put as empty for now, need to recode countries before finding GeoCodes
  #mutate(`Cause of death` = lapply(`Cause of death`, recode_disaster))
  # Need to rename columns to match the ons set

  # Need to replace "Total" in Sex with ""
nomis_deaths <- nomis_deaths %>%
  rename(c(Sex = GENDER_NAME, `Cause of death` = CAUSE_OF_DEATH_NAME, Value = OBS_VALUE, Country = GEOGRAPHY_NAME, Year = DATE)) #%>% 
  #select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)
nomis_deaths <- nomis_deaths %>%
  mutate(`Observation status` = "Normal value") %>%
  mutate(GeoCode = "") %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(`Unit multiplier` = "") %>%
  mutate(Units = "Number") %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

# Keep only the rows for natural disaster deaths
nomis_deaths <- nomis_deaths %>%
  filter(grepl("^[X][0-9][0-9]", `Cause of death`)) # Note: we only match to beginning

# Exclude any rows corresponding to data about non EW residents
nomis_deaths <- nomis_deaths %>% 
  filter(Country %in% c("England", "Wales", "England and wales"))


nomis_deaths <- nomis_deaths %>% 
  mutate(Sex = ifelse(Sex=="Total", "", Sex)) %>% # Might be better to compare to Male and Female 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode))

# Remove the leading code in Cause of death to make match the ons data
nomis_deaths <- nomis_deaths %>% 
  mutate(`Cause of death` = substring(`Cause of death`, 5, nchar(`Cause of death`))) %>% 
  mutate(`Cause of death` = str_to_sentence(`Cause of death`))

# Replace "England and wales" with ""
nomis_deaths <- nomis_deaths %>%
  mutate(Country = ifelse(Country=="England and wales", "", Country))

# Reorder columns to match ons data
nomis_deaths <- nomis_deaths %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

# Now to clean up the mortality data 

nomis_mortality <- nomis_mortality %>% 
  rename(c(Sex = GENDER_NAME, `Cause of death` = CAUSE_OF_DEATH_NAME, Value = OBS_VALUE, Country = GEOGRAPHY_NAME, Year = DATE))
nomis_mortality <- nomis_mortality %>%
  mutate(`Observation status` = "Normal value") %>%
  mutate(GeoCode = "") %>% 
  mutate(Series = "Age-standardised mortality rates per 100,000 population") %>% 
  mutate(`Unit multiplier` = "") %>%
  mutate(Units = "Rate per 100,000 population") %>% 
  #mutate(`Cause of death` = "") %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

###
# Keep only the rows for natural disaster deaths
nomis_mortality <- nomis_mortality %>%
  filter(grepl("^[X][0-9][0-9]", `Cause of death`)) # Note: we only match to beginning

# Exclude any rows corresponding to data about non EW residents
# This shouldn't be needed as we only have total EW data
nomis_mortality <- nomis_mortality %>% 
  filter(Country %in% c("England", "Wales", "England and wales"))


nomis_mortality <- nomis_mortality %>% 
  mutate(Sex = ifelse(Sex=="Total", "", Sex)) %>% # Might be better to compare to Male and Female 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode))

# Remove the leading code in Cause of death to make match the ons data
#nomis_mortality <- nomis_mortality %>% 
  #mutate(`Cause of death` = substring(`Cause of death`, 5, nchar(`Cause of death`))) %>% 
  #mutate(`Cause of death` = str_to_sentence(`Cause of death`))

# Replace "England and wales" with ""
nomis_mortality <- nomis_mortality %>%
  mutate(Country = ifelse(Country=="England and wales", "", Country))

# Finally combine the 3 data tables

all_death_data <- rbind(ons_disaster_deaths_final, nomis_deaths)

combined_dataframe <- rbind(all_death_data, nomis_mortality)

# Remove any rows with NA in the Value column, e.g. at this time the
# mortality data has NA for 2021

combined_dataframe <- combined_dataframe %>% filter(!is.na(Value))

# Rearrange, this ordering of the columns is preferred

combined_dataframe <- combined_dataframe %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

# Set to "" the Cause of death for Age-standardised
# For some reason doing to the nomis mortality set alone would
# cause it to not be added to the final dataset

combined_dataframe <- combined_dataframe %>% 
  mutate(`Cause of death` = ifelse(Series=="Age-standardised mortality rates per 100,000 population", "", `Cause of death`))
