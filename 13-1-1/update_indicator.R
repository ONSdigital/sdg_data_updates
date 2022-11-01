### 13-1-1 ###

# Output table gives number of deaths by cause of death, by sex,
# by country, by year (2001 to present).
# It also gives Age-Standardised mortality rates by Sex for 2013 to present.


# download and read in data ----------------------------------------------------
nomis_deaths <- read.csv(nomis_disaster_deaths_link) %>% # RENAME THESE
  mutate(across(where(is.factor), as.character)) %>% # are these needed?
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

nomis_mortality <- read.csv(nomis_mortality_link) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

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

# In hindsight just this table is probably sufficient but I found it easier to use all four
ons_deaths4 <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons4, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

# ons_disaster_deaths <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons_disaster_deaths_tab, colNames = FALSE) %>%
#   mutate(across(where(is.factor), as.character)) %>% 
#   mutate(across(where(is.character), str_to_sentence)) %>% 
#   mutate(across(where(is.character), str_squish))  

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

# Define some convenience functions for aggregating the data ----------

# This is for ons_deaths2. Aggregates on Sex where Value
# is for all Cause of death
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

# This is for ons_deaths4. Aggregates on Sex where Value
# is the number of deaths caused by the given Cause of death
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

# This is for nomis_deaths. Aggregates Value for the 10 causes of death
get_cod_aggregates <- function(df){
  combinations <- unique(df[c("Country", "Year", "Sex")])
  placeholder <- vector("integer", nrow(combinations))
  for(i in 1:nrow(combinations)){
    cty<-combinations[i,]$Country 
    yr<-combinations[i,]$Year 
    sx<-combinations[i,]$Sex
    toAggregate <- df %>% filter(Country==cty, Year==yr, Sex==sx) %>% select(Value)
    placeholder[i] <- colSums(toAggregate)
  }  
  combinations <- combinations %>% 
    mutate(Value = placeholder)
  return(combinations)
}

# Clean up the ons_deaths tables -----
# ons_deaths1 is all COD all sex (no MALE AND FEMALE aggregate supplied)
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

# Now we need to add rows for the aggregates of Sex which aren't
# present in the source data

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


#
# ons_deaths: Deaths by COD, year and country, aggregated by Sex
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
  
#
# ons_deaths4 is deaths by COD by country by sex by year. 
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

# Now to calculate the values aggregated by sex
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

# Combined all the ons data sets and their aggregations ----
ons_combined <- ons_deaths1 %>% 
  rbind(ons_deaths2) %>% 
  rbind(ons_death2_sex_agg) %>% 
  rbind(ons_deaths3) %>% 
  rbind(ons_deaths4) %>% 
  rbind(ons_death4_sex_agg)

# Now to keep only the rows for Year<2012 as we will use the nomis data after
ons_combined <- ons_combined %>% 
  mutate(Year = as.numeric(Year)) %>% 
  filter(Year <= 2012)

# Now to process the nomis death data ----
# Thankfully this data is already aggregated on Sex
# Still need to aggregate on all cause of death


nomis_deaths <- nomis_deaths %>%
  rename(c(Sex = GENDER_NAME, `Cause of death` = CAUSE_OF_DEATH_NAME, Value = OBS_VALUE, Country = GEOGRAPHY_NAME, Year = DATE)) #%>% 

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
# Now we need to aggregate the cause of deaths so that we have values
# for e.g. number of males killed in Wales in 2018 by any disaster

nomis_deaths_cod_agg <- get_cod_aggregates(nomis_deaths)

nomis_deaths_cod_agg <- nomis_deaths_cod_agg %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature") %>% 
  mutate(`Observation status` = "Normal value") %>% 
  mutate(`Cause of death` = "") %>% 
  mutate(Units = "Number") %>% 
  mutate(`Unit multiplier` = "") %>% 
  mutate(GeoCode = lapply(Country, get_GeoCode)) %>% 
  mutate(GeoCode = as.character(GeoCode)) %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)



# Combine nomis with its aggregate data ----

nomis_combined_deaths <- rbind(nomis_deaths, nomis_deaths_cod_agg)

# Now to clean up the mortality data ----

nomis_mortality <- nomis_mortality %>% 
  rename(c(Sex = GENDER_NAME, `Cause of death` = CAUSE_OF_DEATH_NAME, Value = OBS_VALUE, Country = GEOGRAPHY_NAME, Year = DATE))
nomis_mortality <- nomis_mortality %>%
  mutate(`Observation status` = "Normal value") %>%
  mutate(GeoCode = "") %>% 
  mutate(Series = "Age-standardised mortality rates per 100,000 population") %>% 
  mutate(`Unit multiplier` = "") %>%
  mutate(Units = "Rate per 100,000 population") %>% 
  select(Year, Series, Country, Sex, `Cause of death`, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

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

# Replace "England and wales" with ""
nomis_mortality <- nomis_mortality %>%
  mutate(Country = ifelse(Country=="England and wales", "", Country))

# Finally combine the 3 data tables ----

combined_data <- rbind(ons_combined, nomis_combined_deaths) %>% 
  rbind(nomis_mortality)

# Replace NA with "" for Value

combined_data <- combined_data %>%
  mutate(Value = ifelse(is.na(Value), "", Value))

# Rearrange, this ordering of the columns is preferred

combined_data <- combined_data %>% 
  select(Year, Series, `Cause of death`, Country, Sex, `Observation status`, `Unit multiplier`, `Units`, GeoCode, Value)

# Set to "" the Cause of death for Age-standardised
# For some reason doing to the nomis mortality set alone would
# cause it to not be added to the final dataset

combined_data <- combined_data %>% 
  mutate(`Cause of death` = ifelse(Series=="Age-standardised mortality rates per 100,000 population", "", `Cause of death`))

# Remove the duplicate rows
# In case there are examples where Country, Sex, etc are the same but different Value
all_cols_but_val <- names(combined_data)[1:(ncol(combined_data)-1)]
combined_data <- combined_data[!duplicated(combined_data[all_cols_but_val]),]

save.image("img.RData")
