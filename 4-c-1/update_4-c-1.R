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
         Region = region_name,
         `Local Authority` = la_name,
         Sex = gender,
         Age = age_group,
         Ethnicity = ethnicity_major,
         `Ethnic group` = ethnicity_minor,
         percent = headcount_percent_within_gender_grade) %>%
  select(Year, Region, `Local Authority`, Sex, Age, 
         Ethnicity, `Ethnic group`, headcount, percent, school_type, grade, working_pattern,
         on_route, qts_status)



#### Filter data so only required selections are included ####
filtered_data <- relevant_data %>%
  filter(grade == "Total" & 
         working_pattern == "Total" &
         on_route == "Total" &
         qts_status == "Qualified" |
         qts_status == "Total") 


#### Nursery, secondary, and all schools ####

# Primary has 2 categories, each with a percentage. 
  # Will need to add qualified headcounts and then calculate percentage of total headcount.

# Total is "Total state-funded schools".
# Nursery "LA maintained nursery"
# primary is "LA maintained primary" and "Primary academies"
# secondary is "State funded secondary". 

# Note that the primary academies and state-funded secondary are made up of 
# multiple subcategories of school

non_primary_schools <- filtered_data %>%
  rename(Value = percent) %>%
  filter(qts_status == "Qualified") %>%
  mutate(Series = case_when(
    school_type == "Total state-funded schools" ~ "All state-funded schools",
    school_type == "La maintained nursery" ~ "Nursery",
    school_type == "State-funded secondary" ~ "Secondary")) %>%
  filter(Series == "Nursery" | 
           Series == "All publicly funded schools" |
           Series == "Secondary") %>%
  mutate(Value = as.numeric(Value)) %>%
  select(Year, Series, Region, `Local Authority`, 
                  Sex, Value)

# Please note, selecting qualified removes a lot of other disaggregations. 
  # Hence why age and ethnicity disaggregated data is not available. 
  

#### Primary schools ####

# Primary has 2 categories, each with a percentage. 
# Will need to add qualified headcounts and then calculate percentage of total headcount.

primary_schools_filtered <- filtered_data %>% 
  mutate(Series = case_when(
    school_type == "Primary academies" ~ "Primary",
       school_type == "La maintained primary" ~ "Primary")) %>%
  filter(Series == "Primary" &
         Ethnicity == "Total" &
         grade == "Total" &
         working_pattern == "Total" &
         Age == "Total" & 
         on_route == "Total") %>%
  select(Year, Series, Region, `Local Authority`, 
         Sex, headcount, qts_status)

# replace character NAs with blanks in region and Loal authority
primary_schools_filtered <- primary_schools_filtered %>% 
  mutate_at(c("Region", "Local Authority"), ~replace_na(.,""))

# Combine La maintained primary and Primary academies
all_primaries <- primary_schools_filtered %>%
   group_by(Year, Series, Region, `Local Authority`, Sex, qts_status) %>%
   summarize(headcount = sum(headcount))


# split out qts status into to total and qualified to allow percentage calculation

split_primary_schools <- all_primaries %>%
  pivot_wider(names_from = qts_status,
              values_from = headcount) %>%
  drop_na(Qualified) # removes disaggregations where qualified headcount is not available

# Calculate percentage 
primary_schools <- split_primary_schools %>%
  mutate(Value = 100*(Qualified/Total)) %>% 
  select(Year, Series, Region, `Local Authority`, 
         Sex, Value)



#### Combine the data ####

combined_data <- dplyr::bind_rows(non_primary_schools,
                                  primary_schools) 


#### Formatting the dataframe ####

# add in the extra metadata columns
csv_formatted <- combined_data %>%
  mutate(`Local Authority` = toTitleCase(`Local Authority`),
         Region = toTitleCase(Region)) %>% 
  mutate(`Unit measure` = "Percentage (%)") %>%
  mutate(`Observation status` = case_when(Value != "NA" ~ "Normal value",
                                          TRUE ~ "Missing value")) %>%
  select(Year, Series, Region, `Local Authority`, Sex,
         `Unit measure`, `Observation status`, Value) %>%
  arrange(Year, Series, Region, `Local Authority`, Sex)


# reformat the Sex column
csv_formatted$Sex <- gsub("Total", "", csv_formatted$Sex)


# reformat the years by subbing in " to 20" after the fourth value in the string
csv_formatted$Year <- gsub("^(.{4})(.*)$",         
                           "\\1 to 20\\2",
                           csv_formatted$Year) 

csv_formatted$Region <- gsub("Yorkshire and the Humber", "Yorkshire and The Humber", csv_formatted$Region)

# replace character NAs with blanks in region and Local authority
csv_clean <- csv_formatted %>% 
  mutate_at(c("Region", "Local Authority"), ~replace_na(.,""))


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_clean)) == nrow(csv_clean)


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_clean) 




