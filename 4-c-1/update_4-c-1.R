# author: Michael Nairn
# date: 18/05/2023

# Code to automate data update for indicator 4-c-1 
  # Proportion of teachers with the minimum required qualifications, by education level


#### Read in data ####
raw_data <- get_type1_data(header_row, source_data, workforce_teacher_characteristi) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))


#### Rename and select relevant columns ####
relevant_data <- raw_data %>%
  rename(Year = time_period,
         Country = country_name,
         Region = region_name,
         `Local Authority` = la_name,
         Sex = gender,
         Age = age_group,
         Ethnicity = ethnicity_major,
         `Ethnic group` = ethnicity_minor,
         Value = headcount_percent_within_gender_grade) %>%
  select(Year, Country, Region, `Local Authority`, Sex, Age, 
         Ethnicity, `Ethnic group`, headcount, Value, school_type, grade, working_pattern,
         qts_status)



#### Filter data so only required selections are included
filtered_data <- relevant_data %>%
  filter(grade == "Total" & 
         working_pattern == "Total" &
         qts_status == "Qualified") %>% 
  select(Year, school_type, Country, Region, `Local Authority`, Sex, Value, headcount)

# Please note, selecting qualified removes a lot of other disaggregations. 
  # Hence why age and ethnicity disaggregated data is not available. 
  


#### Categorise into Nursery, Primary, Secondary, Total ####

# not easy for primary and secondary as multiple categories, each with a percentage. 
  # Need full and qualified headcount and then calculate percentages. 


categorised_data <- filtered_data %>%
  mutate(Series = case_when(
    school_type == "Total state-funded schools" ~ "All publicly funded schools (%)",
    school_type == "La maintained nursery" ~ "Nursery (%)"
    school_type == "La maintained primary" ~ "Primary (%)"
    school_type == "La maintained secondary" ~ "Secondary (%)"
    ))


#### Formatting the dataframe ####

# add in the extra metadata columns
csv_formatted <- categorised_data %>%
  mutate(`Local Authority` = toTitleCase(`Local Authority`),
         Region = toTitleCase(Region)) %>% 
  mutate(`Unit measure` = "Percentage (%)") %>%
  mutate(`Observation status` = case_when(Value != "NA" ~ "Normal value",
                                          TRUE ~ "Missing value")) %>%
  select(Year, Series, Country, Region, `Local Authority`, Sex, Value)


# reformat the Sex column
csv_formatted$Sex <- gsub("Total", "", csv_formatted$Sex)


# reformat the years by subbing in " to 20" after the fourth value in the string
csv_formatted$Year <- gsub("^(.{4})(.*)$",         
                           "\\1 to 20\\2",
                           csv_formatted$Year) 


#### Remove NAs from the csv that will be saved in Outputs ####
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
csv_formatted_nas <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value)) 


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted_nas)) == nrow(csv_formatted_nas)


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_formatted_nas) 




