# Author: Emma wood
# Date of writing: 11/12/2020
# Date Last updated:
# Last updated by:
# Purpose: format data for 15-1-2 from Geospatial and create plots to check for stories/ possible errors
#          this code may need to be edited in order to be used for updates 

'%not_in%' <- Negate('%in%')

library(ggplot2)

Date <- Sys.Date()

original_data <- read.csv(input_filepath) %>% 
  mutate(KBA_IN_PA_AREA_ha = ifelse(KBA_IN_PA_AREA_ha == " -   ", "0" , as.character(KBA_IN_PA_AREA_ha))) %>%  
  mutate(KBA_IN_PA_AREA_ha = as.numeric(KBA_IN_PA_AREA_ha))

# add rows for England and UK
England_data <- original_data %>% 
  filter(RGN19NM != "England" & RGN19NM != "ENGLAND" & # these are not currently in the data, but just in case they are added in in future years this is a failsafe
           CTRY19NM == "ENGLAND") %>% 
  group_by(LCM_AGGREGATE_NAME, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha),
            PA_ha = sum(PA_ha)) %>% 
  mutate(CTRY19NM = "ENGLAND",
         RGN19NM = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

UK_data <- original_data %>% 
  filter(RGN19NM != "England" & RGN19NM != "ENGLAND") %>%  # these are not currently in the data, but just in case they are added in in future years this is a failsafe 
  group_by(LCM_AGGREGATE_NAME, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha),
            PA_ha = sum(PA_ha)) %>% 
  mutate(CTRY19NM = "",
         RGN19NM = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

# join England and UK data to the regional data  
all_countries <- bind_rows(England_data, UK_data, original_data) 

# add headline data for ecosystems
all_ecosystems <- all_countries %>% 
  group_by(CTRY19NM, RGN19NM, RGN19CD, YEAR) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha),
            PA_ha = sum(PA_ha)) %>%
  mutate(LCM_AGGREGATE_NAME = "",
         PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100)

# add headline figures for all ecosystems to rest of data  
all_data <- bind_rows(all_ecosystems, all_countries)

terrestrial <- c("Arable", "Broadleaf woodland", "Built-up areas and gardens", 
                 "Coniferous woodland", "Improved grassland", "Semi-natural grassland")

# layout data to match our csv layout
England_geocode <- "E92000001"
  
long_format_for_csv <- all_data %>% 
  rename(Year = YEAR,
         Country = CTRY19NM,
         Region = RGN19NM,
         `Ecosystem type` = LCM_AGGREGATE_NAME,
         `Key Biodiversity Areas` = KBA._AREA_ha,
         `Key Biodiversity Areas within protected areas (ha)` = KBA_IN_PA_AREA_ha,
         `Key Biodiversity Areas within protected areas (%)` = PROPORTION_OF_KBA_IN_PA_pct,
         `Protected Areas` =  PA_ha,
         GeoCode = RGN19CD) %>% 
  mutate(GeoCode = ifelse(Country == "ENGLAND" & Region == "", England_geocode, as.character(GeoCode)),
         GeoCode = ifelse(is.na(GeoCode), "", as.character(GeoCode))) %>% 
  mutate(Country = str_to_title(Country)) %>% 
  mutate(Region = ifelse(Country != "England", "", Region)) %>% 
  select(-c(CTRY19CD, LCM_AGGREGATE_CLASS_NUMBER, rgn19cd_AGG_NAME)) %>% 
  pivot_longer(-c(Year, Country, Region, `Ecosystem type`, GeoCode), 
               names_to = "Units",
               values_to = "Value") %>% 
  mutate(
    Series = case_when(
      Units == "Key Biodiversity Areas within Protected Areas (ha)" |
        Units == "Key Biodiversity Areas within protected areas (%)" ~ 
        "Key Biodiversity Areas within Protected Areas",
      TRUE ~ as.character(Units)),
    Units = case_when(
      Units == "Key Biodiversity Areas within protected areas (%)" ~ "Percentage (%)",
      TRUE ~ as.character("Hectares (ha)"))
    ) %>% 
  mutate(`Unit measure` = Units,
         `Unit multiplier` = "Units") %>% 
  # region should be "East" in tables and charts rather than "East of England" (which should be used in text)
  mutate(Region = ifelse(Region == "East of England", "East", Region)) %>% 
  # # change values to thousands - decided against this as the region by ecosystem type values are often <1000
  # mutate(Value = ifelse(`Unit measure` == "Hectares (ha)", Value / 1000, Value),
  #        `Unit multiplier` = "Thousands") %>% 
  select(Year, Country, Region, `Ecosystem type`, Series,
         Units, `Unit measure`, `Unit multiplier`,  
         GeoCode, Value) 

#--------------------------------------------------------------------------------
# calculate numbers for the broader categories (for comparison with IBAT)
broad_ecosystems <- all_data %>% 
  filter(RGN19NM %in% c("", "Scotland", "Wales", "Northern Ireland")) %>% 
  mutate(Category = case_when(
    LCM_AGGREGATE_NAME %in% terrestrial ~ "terrestrial",
    LCM_AGGREGATE_NAME == "Coastal" | LCM_AGGREGATE_NAME == "Saltwater" ~ "marine",
    LCM_AGGREGATE_NAME == "Mountain, heath, bog" ~ "mountain",
    LCM_AGGREGATE_NAME == "Freshwater" ~ "freshwater",
    TRUE ~ as.character(LCM_AGGREGATE_NAME))) 

broad_ecosystems_UK <- broad_ecosystems %>% 
  filter(CTRY19NM == "") %>% 
  group_by(YEAR, Category) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha),
            PA_ha = sum(PA_ha)) %>% 
  mutate(PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100) %>% 
  mutate(Geography = "UK")

broad_ecosystems_GB <- broad_ecosystems %>% 
  mutate(GB = ifelse(CTRY19NM %in% c("ENGLAND", "WALES", "SCOTLAND"), TRUE, FALSE)) %>% 
  filter(GB == TRUE) %>% 
  group_by(YEAR, Category) %>% 
  summarise(KBA._AREA_ha = sum(KBA._AREA_ha),
            KBA_IN_PA_AREA_ha = sum(KBA_IN_PA_AREA_ha),
            PA_ha = sum(PA_ha)) %>% 
  mutate(PROPORTION_OF_KBA_IN_PA_pct = (KBA_IN_PA_AREA_ha/KBA._AREA_ha)*100) %>% 
  mutate(Geography = "GBR")

broad_ecosystems_GB_UK <- bind_rows(broad_ecosystems_GB, broad_ecosystems_UK) %>% 
  mutate(Category = ifelse(Category == "", "all", Category)) %>% 
  mutate(Category = tolower(Category))

#-------------------------------------------------------------------------------
# save files
available_folders <- list.files()
if('Output' %not_in% available_folders) {
  dir.create('Output')
}
write.csv(long_format_for_csv, paste0('Output/csv_', Date, '.csv'), row.names = FALSE)
write.csv(broad_ecosystems_GB_UK, paste0('Output/to_check_against_IBAT_', Date, '.csv'), row.names = FALSE)

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

Units_list <- unique(region_data$Units)
Ecosystem_list <- unique(region_data$`Ecosystem type`)

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


pdf(paste0('Output/Plots_', Date, '.pdf'))

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

# ------------------------------------------------------------------------------
# Check data against IBAT

if(IBAT_data_available == TRUE) {
  
  IBAT <- read.csv(IBAT_data_filepath) %>% 
    filter(year >= min(long_format_for_csv$Year)) %>% 
    mutate(Subset = tolower(Subset),
           dataset = "IBAT")
  
  UK_IBAT_comparison <- broad_ecosystems_GB_UK %>% 
    rename(year = YEAR,
           Subset = Category,
           Mean.PA.coverage.of.KBAs = PROPORTION_OF_KBA_IN_PA_pct,
           dataset = Geography) %>% 
    bind_rows(IBAT) 
  
  pdf(paste0('Output/IBAT_comparison_plots_', Date, '.pdf'))
  
  comparison_plot <- ggplot(
    UK_IBAT_comparison,
    aes(x = year,
        y = Mean.PA.coverage.of.KBAs,
        colour = dataset)) +
    geom_point() +
    geom_line() +
    facet_wrap(vars(Subset), nrow = 2) +
    theme_bw()
  
  print(comparison_plot)

  dev.off()
  
}
