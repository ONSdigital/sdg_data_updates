# author: Michael Nairn
# date: 18/05/2023

# Code to automate data update for indicator 4-1-1 
  # (Proportion of children and young people - 
  # (a) in grades 2/3; (b) at the end of primary; 
  # and (c) at the end of lower secondary achieving at least a 
  # minimum proficiency level in (i) reading and (ii) mathematics, by sex).


#### Read in data ####
ks1_England_data <- read_csv(ks1_England) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>%
  mutate(Series = "Attainment at age 7")

ks1_LAs_data <- read_csv(ks1_LAs) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>%
  mutate(Series = "Attainment at age 7")

ks2_data <- read_csv(ks2) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>%
  mutate(Series = "Attainment at age 11")

ks4_data <- read_csv(ks4) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) %>%
  mutate(Series = "Attainment at age 16")



#### Combine ks1_LAs and ks2 dataframes as in same format ####

# remove "ta" from percentage met columns of ks1_LAs 
ks1_LAs_data <- ks1_LAs_data %>%
  rename(pt_read_met_expected_standard = pt_readta_met_expected_standard,
         pt_mat_met_expected_standard = pt_matta_met_expected_standard)

ks1_LAs_and_ks2 <- rbind(ks1_LAs_data, 
                         ks2_data)


#### Manipulate ks1_LAs and ks2 data ####

# select and rename relevant columns
ks1_LAs_and_ks2_small <- ks1_LAs_and_ks2 %>%
  rename(Year = time_period,
         Sex = gender,
         Country = country_name,
         Region = region_name,
         `Local Authority` = la_name,
         Reading = pt_read_met_expected_standard,
         Maths = pt_mat_met_expected_standard) %>%
  select(Year, Series, Country, Region, `Local Authority`,
         characteristic, Sex, Reading, Maths)

# split out characteristics into disaggregations
ks1_LAs_and_ks2_disaggs <- ks1_LAs_and_ks2_small %>%
  mutate(`Disadvantaged status` = case_when
         (characteristic == "Disadvantaged" | 
             characteristic == "Not known to be disadvantaged" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`First language` = case_when
         (characteristic == "First language unclassified" |
             characteristic == "Language unclassified" |
             characteristic == "Known or believed to be english" | 
             characteristic == "Known or believed to be other than english" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`Free school meal status` = case_when
         (characteristic == "Fsm eligible" |
             characteristic == "Not known to be fsm eligible"  ~ characteristic,
           TRUE ~ "")) %>% 
  mutate(`Special educational needs (SEN) status` = case_when
         (characteristic == "All sen" |
             characteristic == "No sen" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`Ethnic group` = case_when
         (characteristic == "Asian" | 
             characteristic == "Black" | 
             characteristic == "White" | 
             characteristic == "Mixed" | 
             characteristic == "Unclassified" |
             characteristic == "Any other ethnic group" ~ characteristic,
           TRUE ~ ""))

# split out Reading and Maths
ks1_LAs_and_ks2_reading <- ks1_LAs_and_ks2_disaggs %>%
  mutate(Subject = "Reading") %>% 
  rename(Value = Reading)

ks1_LAs_and_ks2_maths <- ks1_LAs_and_ks2_disaggs %>%
  mutate(Subject = "Maths") %>% 
  rename(Value = Maths)

ks1_LAs_and_ks2_clean <- dplyr::bind_rows(ks1_LAs_and_ks2_maths, ks1_LAs_and_ks2_reading) %>% 
  select(Year, Series, Subject, Country, Region, `Local Authority`, Sex,
         `Ethnic group`, `Special educational needs (SEN) status`,
         `Disadvantaged status`, `Free school meal status`, 
         `Free school meal status`, `First language`, Value) %>%
  mutate(Value = as.numeric(Value))




#### Manipulate ks1_England data ####

# select and rename relevant columns
ks1_England_small <- ks1_England_data %>%
  rename(Year = time_period,
         Sex = gender,
         Country = country_name,
         Reading = pt_readta_met_expected_standard,
         Maths = pt_matta_met_expected_standard) %>%
  mutate(Region = "") %>%
  mutate(`Local Authority` = "") %>%
  select(Year, Series, Country, Region, `Local Authority`,
         characteristic, Sex, Reading, Maths)

# split out characteristics into disaggregations
ks1_England_disaggs <- ks1_England_small %>%
  mutate(`Disadvantaged status` = case_when
         (characteristic == "Disadvantaged" | 
          characteristic == "Not known to be disadvantaged" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`First language` = case_when
         (characteristic == "First language unclassified" |
          characteristic == "Known or believed to be english" | 
          characteristic == "Known or believed to be other than english" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`Free school meal status` = case_when
         (characteristic == "Fsm eligible" |
          characteristic == "Not known to be fsm eligible"  ~ characteristic,
           TRUE ~ "")) %>% 
  mutate(`Special educational needs (SEN) status` = case_when
         (characteristic == "All sen" |
          characteristic == "No sen" ~ characteristic,
           TRUE ~ "")) %>%
  mutate(`Ethnic group` = case_when
         (characteristic == "Asian" | 
             characteristic == "Black" | 
             characteristic == "White" | 
             characteristic == "Mixed" | 
             characteristic == "Unclassified" |
             characteristic == "Any other ethnic group" ~ characteristic,
           TRUE ~ ""))

# split out Reading and Maths
ks1_England_reading <- ks1_England_disaggs %>%
  mutate(Subject = "Reading") %>% 
  rename(Value = Reading)

ks1_England_maths <- ks1_England_disaggs %>%
  mutate(Subject = "Maths") %>% 
  rename(Value = Maths)

ks1_England_clean <- dplyr::bind_rows(ks1_England_maths, ks1_England_reading) %>% 
  select(Year, Series, Subject, Country, Region, `Local Authority`, Sex,
         `Ethnic group`, `Special educational needs (SEN) status`,
         `Disadvantaged status`, `Free school meal status`, 
         `Free school meal status`, `First language`, Value) %>%
  mutate(Value = as.numeric(Value))
  
       
           
#### Manipulate ks4 data ####
ks4_clean <- ks4_data %>%
  rename(Year = time_period,
         Sex = gender,
         Country = country_name,
         Value = percentage_achieving,
         Subject = subject) %>%
  mutate(Ethnicity = "") %>% 
  mutate(`Ethnic group` = "") %>%
  mutate(`Disadvantaged status` = "") %>%
  mutate(`First language` = "") %>%
  mutate(`Free school meal status` = "") %>%
  mutate(`Special educational needs (SEN) status` = "") %>%
  mutate(Region = "") %>%
  mutate(`Local Authority` = "") %>%
  select(Year, Series, Subject, Country, Region, `Local Authority`, Sex,
         `Ethnic group`, `Special educational needs (SEN) status`,
         `Disadvantaged status`, `Free school meal status`, 
         `Free school meal status`, `First language`, Value)

ks4_clean$Subject <- gsub(" language", "", ks4_clean$Subject)





#### Bind all three datasets together ####
combined_data <- dplyr::bind_rows(ks4_clean, ks1_England_clean,
                                  ks1_LAs_and_ks2_clean) 


#### Formatting the dataframe ####

# add in the extra metadata columns
csv_formatted <- combined_data %>%
  mutate(`Local Authority` = toTitleCase(`Local Authority`),
         Region = toTitleCase(Region)) %>% 
  mutate(`Unit measure` = "Percentage (%)") %>%
  mutate(`Observation status` = case_when(Value != "NA" ~ "Normal value",
                                          TRUE ~ "Missing value")) %>%
  select(Year, Series, Subject, Region, `Local Authority`, Sex,
         `Ethnic group`, `Special educational needs (SEN) status`,
         `Disadvantaged status`, `Free school meal status`, `First language`, 
         `Unit measure`, `Observation status`, Value)


# reformat the Sex column
csv_formatted$Sex <- gsub("Total", "", csv_formatted$Sex)
csv_formatted$Sex <- gsub("Boys", "Male", csv_formatted$Sex)
csv_formatted$Sex <- gsub("Girls", "Female", csv_formatted$Sex)


# reformat the years by subbing in " to 20" after the fourth value in the string
csv_formatted$Year <- gsub("^(.{4})(.*)$",         
                           "\\1 to 20\\2",
                           csv_formatted$Year) 

csv_formatted$Subject <- gsub("Mathematics", "Maths", csv_formatted$Subject)
csv_formatted$Region <- gsub("Yorkshire and the Humber", "Yorkshire and The Humber", csv_formatted$Region)
csv_formatted$`Special educational needs (SEN) status` <- gsub("sen", "SEN", 
                                                               csv_formatted$`Special educational needs (SEN) status`)

csv_formatted$`Free school meal status` <- gsub("Fsm eligible", "FSM eligible", 
                                                csv_formatted$`Free school meal status`)
csv_formatted$`Free school meal status` <- gsub("Not known to be fsm eligible", 
                                                "Not known to be FSM eligible", 
                                                csv_formatted$`Free school meal status`)


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




