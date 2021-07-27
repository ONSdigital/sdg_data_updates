# author: Emma Wood
# date: 27/07/2021

library('openxlsx')

woodland_source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", woodland_filename),
                                     sheet = woodland_area_tabname, colNames = FALSE)
certified_source_data <- openxlsx::read.xlsx(paste0(input_folder, "/", woodland_filename),
                                      sheet = certified_area_tabname, colNames = FALSE)
area_source_data <- read.csv(paste0(input_folder, "/", area_filename)) 

# get relevant area data (of all land)
country_column <- which(substr(names(area_source_data), 1, 4) == "CTRY" &
                          substr(names(area_source_data), 7, 8) == "NM")
country_code_column <- which(substr(names(area_source_data), 1, 4) == "CTRY" &
                          substr(names(area_source_data), 7, 8) == "CD")
area_data <- area_source_data 
names(area_data)[country_column] <- "Country"
names(area_data)[country_code_column] <- "Geocode"

relevant_area_data <- select(area_data, Geocode, Country, AREALHECT) %>% 
  add_row(Geocode = "", Country = "UK", AREALHECT = sum(area_data$AREALHECT)) 

# get woodland area data (of all woodland)
header_row_woodland <- which(woodland_source_data$X1 == "Year")

woodland_data_with_header <- woodland_source_data

names(woodland_data_with_header) <- woodland_data_with_header[header_row_woodland, ]

woodland_data <- woodland_data_with_header %>% 
  mutate(Year_entry = grepl('[0-9][0-9][0-9][0-9]',
                            substr(Year, 1, 4)))%>% 
  filter(Year_entry == TRUE) %>% 
  select(-Year_entry) %>% 
  pivot_longer(- Year,
               names_to = "Country",
               values_to = "woodland_area")


# get certified woodland area data 
header_row_certified <- which(certified_source_data$X1 == "Year")

certified_data_with_header <- certified_source_data

names(certified_data_with_header) <- certified_data_with_header[header_row_certified, ]

certified_data <- certified_data_with_header %>% 
  mutate(Year_entry = grepl('[0-9][0-9][0-9][0-9]',
                            substr(Year, 5, 9))) %>% 
  mutate(Year = substr(Year, 5, 9)) %>% 
  filter(Year_entry == TRUE) %>% 
  select(-Year_entry) %>% 
  pivot_longer(- Year,
               names_to = "Country",
               values_to = "certified_area") 


# join data and do calculations
all_data <- woodland_data %>% 
  left_join(certified_data, by = c("Year", "Country")) %>% 
  left_join(relevant_area_data, by = "Country") %>% 
  mutate(Year = as.numeric(Year),
         AREALHECT = as.numeric(AREALHECT),
         woodland_area = as.numeric(woodland_area),
         certified_area = as.numeric(certified_area))

indicator_data <- all_data %>% 
  mutate(woodland_proportion = (woodland_area * 1000000) / AREALHECT * 100,
         certified_proportion = (certified_area * 1000000) / AREALHECT * 100,
         non_certified_proportion = ((woodland_area - certified_area) * 1000000) / AREALHECT * 100) %>% 
  select(-c(woodland_area, certified_area, AREALHECT))

# add required columns, rename disaggregation levels, and filter out values we don't want to display
csv_formatted <- indicator_data %>% 
  pivot_longer(-c(Year, Country, Geocode),
               names_to = "Sustainably managed status",
               values_to = "Value") %>% 
  mutate(`Sustainably managed status` = case_when(
    `Sustainably managed status` == "woodland_proportion" ~ "",
    `Sustainably managed status` == "certified_proportion" ~ "Certified",
    `Sustainably managed status` == "non_certified_proportion" ~ "Non-certified"),
    Country = ifelse(Country == "UK", "", Country)) %>% 
  mutate(different_method = ifelse((Country == "Northern Ireland" | Country == "") & 
                                     Year < 2013 & 
                                     `Sustainably managed status` %in% c("", "Non-certified"),
                                   TRUE, FALSE)) %>% 
  filter(!is.na(Value) & 
           different_method == FALSE &
           Year >= 2004) %>% 
  mutate(`Observation status` = "Undefined",
         `Unit multiplier` = "Units",
         `Unit measure` = "percentage (%)") %>% 
  select(Year, Country, `Sustainably managed status`, 
         `Observation status`, `Unit measure`, `Unit multiplier`,
         Value)
    

  

