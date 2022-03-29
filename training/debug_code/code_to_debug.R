# # author: Emma Wood & Atanaska Nikolova
# # before running the exercise, select all and do ctrl+shift+c to remove the 
# # hashes from the code. (It is all hashed so that the bugs don't interfere with renv)
# # date: 08/03/2021
# 
# library('openxlsx')
# library('dplyr')
# library('tidyr')
# library('stringr')
# 
# woodland_source_data <- openxlsx::read.xlsx("training/debug_code/Example_Input/PWS_2021.xlsx",
#                                      sheet = "woodland_data", colNames = FALSE) %>%
#   mutate(across(where(is.factor), as.character)) %>% 
#   mutate(across(where(is.character), toupper))
# 
# certified_source_data <- openxlsx::read.xlsx("training/debug_code/Example_Input/PWS_2021.xlsx"
#                                       sheet = "certified_data", colNames = FALSE) %>% 
#   mutate(across(where(is.factor), as.character)) %>% 
#   mutate(across(where(is.character), toupper))
# 
# area_source_data <- read.csv("training/clean_code/Example_Input/SAM_CTRY_DEC_2020_UK.csv") %>% 
#   mutate(across(where(is.factor), as.character)) %>% 
#   mutate(across(where(is.character), toupper))
# 
# #---- get relevant area data (of all land) ----#
# # The name of the columns containing country names and codes will change depending on the year. 
# # We therefore need to identify these columns and give them a standard name that 
# #  we can refer to in the code, without having to change it every year:
# country_column <- which(substr(names(area_source_data), 1, 4) == "CTRY"
#                          & substr(names(area_source_data), 7, 8) == "NM")
# country_code_column <- which(substr(names(area_source_data), 1, 4) == "CTRY" &
#                           substr(names(area_source_data), 7, 8) == "CD")
# area_data <- area_source_data 
# names(area_data)[country_column] <- "Country"
# names(area_data)[country_code_column] <- "Geocode"
# 
# country_and_UK_areas <- area_data %>% 
#   select(Geocode, Country, AREALHECT) %>% 
#   add_row(Geocode = "", Country = "UK", AREALHECT = sum(area_data$AREALHECT)) 
# 
# #---- get woodland area data (of all woodland)----#
# # The column names (headers) for the woodland data are not in the first row,
# #  as there is metadata above the data.
# # The row the headers are in may differ for different years, so we identify
# #  which row they are in, using a column name we know will always exist
# header_row_woodland <- which(woodland_source_data$X1 == "Year")
# 
# woodland_data_with_headers <- woodland_source_data
# names(woodland_data_with_headers) <- woodland_data_with_headers[header_row_woodland, ]
# 
# woodland_metadata_removed <- woodland_data_with_headers %>% 
#   # Identify metadata rows by using the year column. 
#   # We know year should have 4 numbers as the first 4 characters, 
#   # so if it doesn't it isn't a data entry.
#   mutate(keep = grepl('[0-9][0-9][0-9][0-9]',
#                             substr(YEAR, 1, 4)))%>% 
#   filter(keep == TRUE) %>% 
#   select(-keep) 
# 
# woodland_data_tidy <- woodland_metadata_removed %>% 
#   pivot_longer(-YEAR,
#                names_to = "Country",
#                values_to = "woodland_area") 
# 
# 
# #---- get certified woodland area data ----#
# header_row_certified <- which(certified_source_data$X1 == "YEAR")
# 
# certified_data_with_headers <- certified_source_data
# names(certified_data_with_headers) <- certified_data_with_headers[header_row_certified, ]
# 
# certified_metadata_removed <- certified_data_with_headers %>% 
#   mutate(keep = grepl('[0-9][0-9][0-9][0-9]', 
#                             substr(YEAR, 5, 9))) %>% 
#   mutate(YEAR = substr(YEAR, 5, 9)) %>% 
#   filter(keep == TRUE) %>% 
#   select(-keep)  
# 
# certified_data_tidy <- certified_metadata_removed %>% 
#   pivot_longer(-YEAR,
#                names_to = "Country",
#                values_to = "certified_area") 
# 
# #--- combine data and create csv ----#
# all_data <- woodland_data_tidy %>% 
#   left_join(certified_data_tidy, by = "YEAR", "Country") %>%
#   left_join(country_and_UK_areas, by = "Country") %>% 
#   mutate(YEAR = as.numeric(YEAR),
#          AREALHECT = as.numeric(AREALHECT),
#          woodland_area = as.numeric(woodland_area),
#          certified_area = as.numeric(certified_area))
# 
# # this block below is copied into the markdown, so if it changes please update
# # that script too
# indicator_data <- all_data %>% 
#   mutate(woodland_proportion = (woodland_area * 1000000) / AREALHECT * 100,
#          certified_proportion = (certified_area * 1000000) / AREALHECT * 100,
#          non_certified_proportion = ((woodland_area - certified_area) * 1000000) / AREALHECT * 100) %>% 
#   select(-c(woodland_area, certified_area, AREALHECT)) 
# 
# # add required columns, rename disaggregation levels, and filter out values we don't want to display
# csv_formatted <- indicator_data %>% 
#   pivot_longer(-c(YEAR, Country, Geocode),
#                names_to = "Sustainably managed status",
#                values_to = "Value") %>% 
#   mutate(`Sustainably managed status` = case_when(
#     `Sustainably managed status` == "woodland_proportion" ~ "",
#     `Sustainably managed status` == "certified_proportion" ~ "Certified",
#     `Sustainably managed status` == "non_certified_proportion" ~ "Non-certified"),
#     Country = ifelse(Country == "UK", "", Country)) %>% 
#   mutate(Country = str_to_title(Country)) %>% 
#   # NI had a different method for calculating the area of non-certified woodland area before 2013, 
#   #  so we need to get rid of rows that are impacted by that different methodology
#   mutate(different_method = ifelse((Country == "Northern Ireland" | "") &
#                                      YEAR < 2013 & 
#                                      `Sustainably managed status` %in% c("", "Non-certified"),
#                                    TRUE, FALSE)) %>% 
#   filter(!is.na(Value) & 
#            different_method == FALSE &
#            YEAR >= 2004) %>% 
#   mutate(`Observation status` = "Undefined",
#          `Unit multiplier` = "Units",
#          `Unit measure` = "percentage (%)") %>% 
#   rename(Year = YEAR) %>% 
#   select(Year, Country, `Sustainably managed status`, 
#          `Observation status`, `Unit measure`, `Unit multiplier`,
#          Value)
# 
# files <- list.files('training/debug_code/') 
# check <- ifelse("Output" %in% existing_files, TRUE, FALSE)
# 
# # If an Output folder already exists don't do anything, but otherwise create one
# if (check = FALSE) { 
#   dir.create("training/debug_code/Output")
# }
# # save the csv
# write.csv(final,'training/debug_code/Output/15-1-1_data',row.names=FALSE)
# 
