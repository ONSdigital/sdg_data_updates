# functions: move to SDGupdater if useful for more indicators:

# # This function looks for all the words given in `pattern` vector to identify which
# # column to rename, and then renames that column with `new_name`
# name_columns <- function(dat, pattern, new_name){
#   
#   column_location <- which(apply(sapply(pattern, grepl, 
#                                         names(dat)), 1, all) == TRUE)
#   names(dat)[column_location] <- new_name
#   return(dat)
#   
# }

library('openxlsx')
library('stringr')
library('janitor')
library('tidyr')
library('dplyr')

library('SDGupdater')

#-------------------------------------------------------------------------------

remove_symbols <- function(column) {
  ifelse(column %in% c("z", ":"),
         NA, 
         as.numeric(column))
}
#-------------------------------------------------------------------------------

source("config.R")

if (pre_2020_data == TRUE) {  
  # datasets after 2018 use an extra tab for England and Wales headline figure
  # so there are two options here
  if(england_and_wales_timeseries_tab_name == "NA"){
    source_data <- tidyxl::xlsx_cells(paste0(input_folder, "/", filename),
                                      sheets = c(area_of_residence_tab_name,
                                                 birthweight_by_mum_age_tab_name,
                                                 country_of_occurrence_by_sex_tab_name,
                                                 country_of_birth_tab_name))
  } else {
    source_data <- tidyxl::xlsx_cells(paste0(input_folder, "/", filename),
                                      sheets = c(england_and_wales_timeseries_tab_name, 
                                                 area_of_residence_tab_name,
                                                 birthweight_by_mum_age_tab_name,
                                                 country_of_occurrence_by_sex_tab_name,
                                                 country_of_birth_tab_name))
  }
  
  source("region.R")
  source("birthweight_by_mum_age.R")
  source("country_of_occurence_by_sex.R")
  
  if(include_country_of_birth == TRUE){ 
    source("country_of_birth.R")
  }else {
    clean_csv_data_country_of_birth <- NULL
  }
  
} else if (pre_2020_data == FALSE) {
  
  source("region_new.R")
  source("birthweight_age_new.R")
  source("country_of_occurence_sex_new.R")
  source("country_of_birth_new.R")
  source("ethnicity_new.R")
  
} else {
  stop("please set pre_2020_data to TRUE or FALSE in the configs")
}

age_order <- data.frame(Age = c("19 and under",
                                "20 to 24",
                                "25 to 29",
                                "30 to 34",
                                "35 to 39",
                                "40 and over"),
                        age_order = c(1:6))
weight_order <- data.frame(Birthweight = c("Under 2500",
                                           "Under 1500",
                                           "Under 1000",
                                           "1000 to 1499",
                                           "1500 to 1999",
                                           "2000 to 2499",
                                           "2500 to 2999",
                                           "3000 to 3499",
                                           "3500 to 3999",
                                           "4000 and over",
                                           "Implausible birthweight",
                                           "Not stated"),
                           weight_order = c(1:12))
country_order <- data.frame(Country = c("England and Wales",
                                        "England and Wales linked deaths",
                                        "England",
                                        "Northern Ireland",
                                        "Scotland",
                                        "Wales"),
                            country_order = c(1:6))

bound_tables <- dplyr::bind_rows(clean_csv_data_area_of_residence,
                                 clean_csv_data_birtweight_by_mum_age,
                                 clean_csv_data_country_by_sex,
                                 clean_csv_data_country_of_birth)
if (pre_2020_data == FALSE) {
  bound_tables <- dplyr::bind_rows(bound_tables, 
                                   clean_csv_data_ethnicity)
}

years <- as.numeric(as.character(unique(bound_tables$Year)))

if (max(years, na.rm = TRUE) >= 2018){

# in tables prior to 2018, the England and Wales figure that is comparable to 
# other 'country of occurrence' countries is in table 2. 
# In 2018 and 2019 table 2 does not include this figure, so need to get it from table 1.
# This is where 'england_and_wales.R' will be sourced when we know what format the table will settle in
# as it needs to take 'year' from bound_tables
  
  if (pre_2020_data == TRUE) {
    
    source("england_and_wales.R")
    
  } else if (pre_2020_data == FALSE) {
    
    source("england_and_wales_new.R")
    
    }

  bound_tables <- dplyr::bind_rows(bound_tables, 
                                   clean_csv_data_england_and_wales)
}

csv_data <- bound_tables %>%
  dplyr::left_join(age_order, by = "Age") %>% 
  dplyr::left_join(country_order, by = "Country") %>% 
  dplyr::left_join(weight_order, by = "Birthweight") %>% 
  dplyr::mutate(`Units` = "Rate per 1,000 live births",
                `Unit multiplier` = "Units",
                GeoCode = ifelse(is.na(GeoCode), "", as.character(GeoCode))) %>% 
  dplyr::arrange(`Neonatal period`, age_order, weight_order, country_order, 
                 Region, Sex) %>%
  dplyr::select(Year, `Neonatal period`, Age, Birthweight, Country, Region, 
                `Country of birth`, `Ethnic group`, Sex, 
                GeoCode, `Units`, `Unit multiplier`, `Observation status`, Value)

# Remove low reliability disaggregations ---------------------------------------
# I have decided to remove some disaggregations due to large numbers of rates 
# with low reliability. Someone may wish to reverse this decision in the future.
# If so, this next block (up to the dashed line) can just be commented out.

csv_data <- csv_data %>% 
  mutate(remove = case_when(
    Age != "" & Birthweight != "" ~ TRUE,
    Sex != "" & `Neonatal period` == "Late neonatal" & 
      Country %in% c("Northern Ireland", "Scotland", "Wales") ~ TRUE,
    TRUE ~ FALSE # this line makes all other cases FALSE
  )) %>% 
  filter(remove == FALSE) %>% 
  select(-remove)


#-------------------------------------------------------------------------------

no_value_rows <- csv_data %>%
  dplyr::filter(is.na(Value))

current_directory <- getwd()
year <- SDGupdater::unique_to_string(SDGupdater::get_all_years(csv_data$Year))

# Don't want to overwrite an Output folder that already exists, or depend on the user having remembered to create an Output folder themselves
existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}

date_time <- Sys.time()
filename_date_time <- SDGupdater::create_datetime_for_filename(date_time)

csv_data_filename <- paste0('Output/', filename_date_time, "_3-2-2_data_for_", year, ".csv")
markdown_filename <- paste0('Output/',filename_date_time, "_3-2-2_QA_for_", year, ".html")

write.csv(csv_data, csv_data_filename, row.names = FALSE, na = "")
rmarkdown::render('QA.Rmd', output_file = markdown_filename)

message(paste0("csv for ", year, " has been created and saved in '", current_directory,
             "' as '", csv_data_filename, "\n\n",
             " Please also read the QA document '", markdown_filename, "'"))

# so we end on the same directory as we started:
setwd("./..")

