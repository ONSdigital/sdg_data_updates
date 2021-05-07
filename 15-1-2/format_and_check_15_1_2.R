# Author: Emma wood
# Date of writing: 11/12/2020
# Date Last updated:
# Last updated by:
# Purpose: format data for 15-1-2 from Geospatial and create plots to check for stories/ possible errors
#          this code may need to be edited in order to be used for updates 

'%not_in%' <- Negate('%in%')

library(tidyr)
library(dplyr)
library(ggplot2)
library(stringr) # for str_to_title

Date <- "Dec_2020"

setwd('Y:\\Data Collection and Reporting\\Jemalex\\Code for updates\\15.1.2_initial_data_check_and_format')
original_data <- read.csv('Input\\SDG1512_FINAL_OUTPUT.csv')

# add rows for England and UK
England_data <- original_data %>% 
  filter(RGN19NM != "England" & RGN19NM != "ENGLAND" & # these are not currently in the data, but just in case they are added in in future years this is a failsafe
           CTRY19NM == "ENGLAND") %>% 
  group_by(LCM_AGGREGATE_NAME, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha)) %>% 
  mutate(CTRY19NM = "ENGLAND",
         RGN19NM = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

UK_data <- original_data %>% 
  filter(RGN19NM != "England" & RGN19NM != "ENGLAND") %>%  # these are not currently in the data, but just in case they are added in in future years this is a failsafe 
  group_by(LCM_AGGREGATE_NAME, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha)) %>% 
  mutate(CTRY19NM = "",
         RGN19NM = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

# join England and UK data to the regional data  
all_countries <- bind_rows(England_data, UK_data, original_data)

# add headline data for ecosystems
all_ecosystems <- all_countries %>% 
  group_by(CTRY19NM, RGN19NM, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha)) %>%
  mutate(LCM_AGGREGATE_NAME = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

# add headline figures for all ecosystems to rest of data  
all_data <- bind_rows(all_ecosystems, all_countries)

# layout data to match our csv layout
England_geocode <- "E92000001"
  
long_format_for_csv <- all_data %>% 
  rename(Year = YEAR,
         Country = CTRY19NM,
         Region = RGN19NM,
         `Ecosystem type` = LCM_AGGREGATE_NAME,
         `Area of Key Biodiversity Areas (ha)` = KBA._AREA_ha,
         `Area of Key Biodiversity Areas within protected areas (ha)` = KBA_IN_PA_AREA_ha,
         `Area of Key Biodiversity Areas within protected areas (%)` = PROPORTION_OF_KBA_IN_PA_pct,
         GeoCode = RGN19CD) %>% 
  mutate(GeoCode = ifelse(Country == "ENGLAND" & Region == "", England_geocode, as.character(GeoCode)),
         GeoCode = ifelse(is.na(GeoCode), "", as.character(GeoCode))) %>% 
  mutate(Country = str_to_title(Country)) %>% 
  mutate(Region = ifelse(Country != "England", "", Region)) %>% 
  select(-c(ï..CTRY19CD, LCM_AGGREGATE_CLASS_NUMBER)) %>% 
  pivot_longer(-c(Year, Country, Region, `Ecosystem type`, GeoCode), 
               names_to = "Units",
               values_to = "Value") %>% 
  mutate(`Unit measure` = ifelse(Units == "Area of Key Biodiversity Areas within protected areas (%)", "Percentage (%)", "Hectares (ha)"),
         `Unit multiplier` = Units) %>% 
  # region should be "East" in tables and charts rather than "East of England" (which should be used in text)
  mutate(Region = ifelse(Region == "East of England", "East", Region)) %>% 
  # # change valus to thousands - decided against this as the region by ecosystem type values are often <1000
  # mutate(Value = ifelse(`Unit measure` == "Hectares (ha)", Value / 1000, Value),
  #        `Unit multiplier` = "Thousands") %>% 
  # order columns
  select(Year, Country, Region, `Ecosystem type`, 
         Units, `Unit measure`, `Unit multiplier`,  
         GeoCode, Value) 

# save file
setwd("./Output")
write.csv(long_format_for_csv, paste0('csv_', Date, '.csv'), row.names = FALSE)

##########################################################################################  
# create pdf of plots to check for anything weird/interesting - put this in outputs folder

big_countries <- c("", "England")

region_data <- long_format_for_csv %>% 
  mutate(Region = ifelse(Region == "", Country, Region)) %>% 
  filter(`Ecosystem type` != "" & Region %not_in% big_countries)
country_data <- long_format_for_csv %>% 
  filter(`Ecosystem type` != "" & Region == "") %>% 
  mutate(Region = Country)
total_ecosystems_region_data <- long_format_for_csv %>% 
  mutate(Region = ifelse(Region == "", Country, Region)) %>% 
  filter(`Ecosystem type` == "" & Region %not_in% big_countries)
total_ecosystems_country_data <- long_format_for_csv %>% 
  filter(`Ecosystem type` == "" & Region == "") %>% 
  mutate(Region = Country)

Units_list <- unique(data_regions$Units)
Ecosystem_list <- unique(data_regions$`Ecosystem type`)

plot_data <- function(data_for_plot){
  data_for_plot %>% 
    filter(Units == Units_list[i] &
             `Ecosystem type` == Ecosystem_list[j]) %>% 
    ggplot(data = .,
           aes(x = Year,
               y = Value,
               colour = Region)) +
    geom_point() +
    geom_line() +
    theme_bw() +
    ggtitle(paste(Units_list[i], "\n", Ecosystem_list[j]))
}

plot_totals_data <- function(data_for_plot){
  data_for_plot %>% 
    filter(Units == Units_list[i]) %>% 
    ggplot(data = .,
           aes(x = Year,
               y = Value,
               colour = Region)) +
    geom_point() +
    geom_line() +
    theme_bw() +
    ggtitle(paste(Units_list[i], "\n"))
}


pdf(paste0('Plots_', Date, '.pdf'))

for (i in 1:length(Units_list)){
  
  for (j in 1:length(Ecosystem_list)) {
    
    all_countries_plot <- plot_data(country_data)
    all_regions_plot <- plot_data(region_data)
    
    print(all_countries_plot)
    print(all_regions_plot)

  }
  
  all_ecosystems_country_plot <- plot_totals_data(total_ecosystems_country_data)
  all_ecosystems_region_plot <- plot_totals_data(total_ecosystems_region_data)
  
  print(all_ecosystems_country_plot)
  print(all_ecosystems_region_plot)
}

dev.off()

