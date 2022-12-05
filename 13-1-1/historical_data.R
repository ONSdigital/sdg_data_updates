# This file is called by compile_tables.R if in config.R: run_historic_data <- TRUE.
# This processes the data processes the data on deaths by natural disaster 
# released by the ONS for the years 2001-2018, but outputs for 2001-2012 only.

# Load in the datasets----
headline_df <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons1, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

sex_df <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons2, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>%
  mutate(across(where(is.character), str_to_sentence)) %>%
  mutate(across(where(is.character), str_squish))  

cause_df <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons3, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

cause_by_sex_df <- openxlsx::read.xlsx(ons_disaster_death_link, sheet = ons4, colNames = FALSE) %>%
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))  

# Define functions----

recode_disaster <- function(codeValue){
  codes <- c("X30","X31","X32","X33","X34","X35","X36","X37","X38","X39", "")
  desc <- c("Exposure to excessive natural heat",
            "Exposure to excessive natural cold",
            "Exposure to sunlight",
            "Victim of lightning",
            "Victim of earthquake",
            "Victim of volcanic eruption",
            "Victim of avalanche, landslide and other earth movements",
            "Victim of cataclysmic storm",
            "Victim of flood",
            "Exposure to other and unspecified forces of nature",
            "")
  
  code_to_desc <- data.frame(codes, desc)
  
  
  val <- desc[which(codes==codeValue)]
  return(val)
}

get_GeoCode <- function(countryName){
  if(countryName=="England") {return("E92000001")}
  else if(countryName=="Wales") {return("W92000004")}
  else if(countryName=="") {return("K04000001")}
  else {return("")}
}

# Clean up headline_df----
headline_df_cleaned <- headline_df
header_headline_df <- which(headline_df$X1 == "Country")
names(headline_df_cleaned) <- headline_df[header_headline_df,]
headline_df_cleaned <- headline_df_cleaned %>% 
  tail(-header_headline_df) %>% 
  select(Country, # Some of the tables have unnamed columns so this saves work later
         `Registration year`, 
         Deaths) %>% 
  tidyr::fill(c('Country')) %>% 
  rename(Year = `Registration year`,
         Value = Deaths) %>% 
  mutate(Sex = "",
         `Cause of death` = "",
         Value = as.numeric(Value))

# Clean up sex_df----
sex_df_cleaned <- sex_df
header_sex_df <- which(sex_df$X1 == "Country")
names(sex_df_cleaned) <- sex_df[header_sex_df,]
sex_df_cleaned <- sex_df_cleaned %>% 
  tail(-header_sex_df) %>% 
  select(Country, 
         Sex, 
         `Registration year`, 
         Deaths) %>% 
  tidyr::fill(c('Country', 'Sex')) %>% 
  rename(Year = `Registration year`,
         Value = Deaths) %>% 
  mutate(`Cause of death` = "",
         Value = as.numeric(Value))


# We now need to aggregate by Sex

sex_df_cleaned_agg_by_sex <- sex_df_cleaned %>% 
  group_by(Year, Country) %>% 
  summarise(Value = sum(Value)) %>% 
  mutate(`Cause of death` = "",
         Sex = "")

# Clean up cause_df----

cause_df_cleaned <- cause_df
header_cause_df <- which(cause_df$X1 == "Country")
names(cause_df_cleaned) <- cause_df[header_cause_df,]
cause_df_cleaned <- cause_df_cleaned %>% 
  tail(-header_cause_df)

# Find the columns with COD codes e.g. X32
cause_of_death_bool <- grepl("^[X][3][0-9]$", names(cause_df_cleaned))
cause_of_death_names <- names(cause_df_cleaned)[cause_of_death_bool]

cause_df_cleaned <- cause_df_cleaned %>% 
  select('Country',
         'Year', 
         cause_of_death_names) %>% 
  tidyr::fill(c('Country')) %>% # Seems to break if you take out tidyr::
  tidyr::pivot_longer(cols=cause_of_death_names, names_to="Cause of death", values_to = "Value") %>% 
  mutate(Sex = "",
         Value = as.numeric(Value))

# Clean up cause_by_sex_df----

cause_by_sex_df_cleaned <- cause_by_sex_df
header_cause_by_sex_df <- which(cause_by_sex_df$X1 == "Country")
names(cause_by_sex_df_cleaned) <- cause_by_sex_df[header_cause_by_sex_df,]
cause_by_sex_df_cleaned <- cause_by_sex_df_cleaned %>% 
  tail(-header_cause_by_sex_df)

cause_of_death_bool <- grepl("^[X][3][0-9]$", names(cause_by_sex_df_cleaned)) 
cause_of_death_names <- names(cause_by_sex_df_cleaned)[cause_of_death_bool]

cause_by_sex_df_cleaned <- cause_by_sex_df_cleaned %>% 
  select('Country',
         'Sex',
         'Year', 
         cause_of_death_names) %>% 
  tidyr::fill(c('Country', 'Sex')) %>% # Not sure why but it has to start tidyr::
  tidyr::pivot_longer(cols=cause_of_death_names, names_to="Cause of death", values_to = "Value") %>% 
  mutate(Value = as.numeric(Value))


# Combine all the dataframes----

historic_data <- headline_df_cleaned %>% 
  bind_rows(sex_df_cleaned) %>% 
  bind_rows(sex_df_cleaned_agg_by_sex) %>% 
  bind_rows(cause_df_cleaned) %>% 
  bind_rows(cause_by_sex_df_cleaned)

# Add extra columns and give columns appropriate datatypes----

historic_data_added_cols <- historic_data %>% 
  mutate(Series = "Number of deaths from exposure to forces of nature",
         `Unit multiplier` = "", 
          Units = "Number",
         `Observation status` = all_deaths$OBS_STATUS_NAME %>% unique(), # I.e. whatever Nomis says
         Country = ifelse(Country == "England and wales", "", Country),
         GeoCode = lapply(Country, get_GeoCode) %>% as.character(),
         `Cause of death` = lapply(`Cause of death`, recode_disaster) %>% as.character())

# Keep only data for 2001 to 2012

historic_data_up_to_2012 <- historic_data_added_cols %>%
  filter(Year < 2013) %>%
  select(Year,
         Series,
         Country,
         Sex,
         `Cause of death`,
         `Observation status`,
         `Unit multiplier`,
         `Units`,
         GeoCode,
         Value)


historic_data_up_to_2012_cleaned <- historic_data_up_to_2012 %>%
    mutate(Year = as.numeric(Year),
          Value = as.numeric(Value))
  
