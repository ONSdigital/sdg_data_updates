# author: Michael Nairn
# date: 18/05/2023

# Code to automate data update for indicator 4-2-2 
  # Participation rate in organized learning 
  # (one year before the official primary entry age), by sex) 

# use 4-1-1 as a starting point if further disaggs can be added in future

#### Read in data ####

source_data_registered <- readr::read_csv(file = paste0(input_folder, "/", registered_file))
# source_data_disadvantaged <- readr::read_csv(file = paste0(input_folder, "/", disadvantaged_file))
# source_data_ethnicity_sen <- readr::read_csv(file = paste0(input_folder, "/", ethnicity_sen_file))      


#### Rename and select relevant columns ####

clean_data <- source_data_registered  %>%
  rename(Year = time_period,
         Region = region_name,
         `Local authority` = la_name,
         Age = age,
         Value = percentage_eligible_children) %>%
  select(Year, Age, Region, `Local authority`, Value)


#### Formatting the dataframe ####

# add in the extra metadata columns
csv_formatted <- clean_data %>%
  mutate(`Local authority` = toTitleCase(`Local authority`),
         Region = toTitleCase(Region)) %>% 
  mutate(`Unit measure` = "Percentage (%)") %>%
  mutate(`Observation status` = case_when(Value == "u" ~ "Missing data; low reliability",
                                          TRUE ~ "Normal value")) %>%
  select(Year, Age, Region, `Local authority`, `Unit measure`, `Observation status`, Value)


# reformat the Age column
csv_formatted$Age <- gsub("2-year-olds", "2", csv_formatted$Age)
csv_formatted$Age <- gsub("3-year-olds", "3", csv_formatted$Age)
csv_formatted$Age <- gsub("4-year-olds", "4", csv_formatted$Age)
csv_formatted$Age <- gsub("3 and 4-year-olds", "3 and 4", csv_formatted$Age)
csv_formatted$Age <- gsub("Total", "", csv_formatted$Age)

csv_formatted$Value <- gsub("u", "", csv_formatted$Value)

csv_formatted$Region <- gsub("Yorkshire and the Humber", "Yorkshire and The Humber", csv_formatted$Region)


#### Remove NAs from the csv that will be saved in Outputs ####
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_formatted_nas <- csv_formatted %>% 
  mutate(Region = ifelse(is.na(Region), "", Region)) %>%
  mutate(`Local authority` = ifelse(is.na(`Local authority`), "", `Local authority`)) 


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted_nas)) == nrow(csv_formatted_nas)


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_formatted_nas) %>%
  arrange(Year, Age, Region, `Local authority`)




