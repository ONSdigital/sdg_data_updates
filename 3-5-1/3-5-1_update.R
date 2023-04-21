# Date: 12/04/2023
# Author: Michael Nairn


#### Read in treatment numbers data #### 
England_data <- read.csv(paste0(input_folder, "/", treatment_England)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


LA_data <- read.csv(paste0(input_folder, "/", treatment_LA)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Select and rename columns from England treatment data ####

England_clean <- England_data %>%
  rename(Year = ReportingPeriod_Data, Area = Area_Data, Sex = Gender_Data, 
         Age = AgeGroup_Data, Total = Num_InTreatment_AllInTx,
         drug_group = DrugGroup_Data, 
         Ethnicity_white = Eth_White_AllInTx, 
         Ethnicity_mixed = Eth_Mixed_AllInTx, 
         Ethnicity_asian = Eth_Asian_AllInTx, 
         Ethnicity_black = Eth_Black_AllInTx, 
         Ethnicity_other = Eth_Other_AllInTx) %>% 
  select(Year, Area, Sex, Age, drug_group,
         Ethnicity_white, Ethnicity_mixed, Ethnicity_asian, 
         Ethnicity_black, Ethnicity_other, Total)


#### Select and rename relevant columns from LA treatment data ####

LA_clean <- LA_data %>% 
  rename(Year = ReportingPeriod, Sex = sex, Age = age_group,
         Total = intreatment_allintx, 
         Ethnicity_white = eth_white_allintx, 
         Ethnicity_mixed = eth_mixed_allintx, 
         Ethnicity_asian = eth_asian_allintx, 
         Ethnicity_black = eth_black_allintx, 
         Ethnicity_other = eth_other_allintx) %>% 
  mutate(Ethnicity_white = as.integer(Ethnicity_white),
         Ethnicity_mixed = as.integer(Ethnicity_mixed),
         Ethnicity_asian = as.integer(Ethnicity_asian),
         Ethnicity_black = as.integer(Ethnicity_black),
         Ethnicity_other = as.integer(Ethnicity_other),
         Total = as.integer(Total)) %>%
  select(Year, Area, Sex, Age, drug_group,
         Ethnicity_white, Ethnicity_mixed, Ethnicity_asian, 
         Ethnicity_black, Ethnicity_other, Total)



#### Bind England and LA treatment data #### 

treatment_numbers <- dplyr::bind_rows(England_clean,
                                      LA_clean)


#### Read in unmet need data ####
unmet_opiates_data <- read.csv(paste0(input_folder, "/", unmet_opiates)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

unmet_alcohol_data <- read.csv(paste0(input_folder, "/", unmet_alcohol)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Bind unmet need data ####
unmet_need_data <- dplyr::bind_rows(unmet_alcohol_data,
                                    unmet_opiates_data)

#### Select and rename relevant columns of unmet need data ####

unmet_need_clean <- unmet_need_data %>%
  rename(Year = Time.period,
         Area = Area.Name,
         drug_group = Indicator.Name,
         unmet_need = Value) %>% 
  mutate(Series = "Met need (%)",
         Units = "Percentage (%)") %>%
  select(Year, Series, drug_group, Area, Sex, Age, Units, unmet_need)


#### Calculate met need ####
met_need <- unmet_need_clean %>%
  mutate(Value = 100 - unmet_need) %>% 
  select(-unmet_need)



#### Recode age, sex, and drug group ####

treatment_numbers_clean <- treatment_numbers %>%
  mutate(Sex = recode(Sex, "Total" = "", "F" = "Female", "M" = "Male")) %>%
  mutate(Age = gsub("\\-", " to ", Age), 
         Age = gsub("\\+", " and over", Age),
         Age = gsub("Total", "", Age),
         Age = str_to_sentence(Age)) %>%
  mutate(`Drug group` = recode(drug_group,
                               Total = ""))
  

met_need_clean <- met_need %>%
  mutate(Sex = recode(Sex, "Persons" = "")) %>%
  mutate(Age = gsub("\\-", " to ", Age), 
         Age = gsub("\\+", " and over", Age),
         Age = gsub(" yrs", "", Age),
         Age = str_to_sentence(Age)) %>%
  mutate(`Drug group` = recode(drug_group, 
                               "Proportion of dependent drinkers not in treatment (%) (current method)" = "Alcohol",
                               "Proportion of opiates and/or crack cocaine users (i.e. Ocu) not in treatment (%)" = "Opiates"))


#### Add in geography disaggs ####
treatment_numbers_clean <- treatment_numbers_clean %>% 
  mutate(Country = "England",
         Units = "Number",
         Series = "People in treatment") %>%
  mutate('Local authority' = case_when(
    Area == "England" ~ "", 
    TRUE ~ toTitleCase(Area))) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity_white, Ethnicity_mixed, Ethnicity_asian, 
         Ethnicity_black, Ethnicity_other, Units, Total)


met_need_clean <- met_need_clean %>% 
  mutate(Ethnicity = "") %>%
  mutate(Country = "England") %>%
  mutate('Local authority' = case_when(
    Area == "England" ~ "", 
    TRUE ~ toTitleCase(Area))) %>% 
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)


#### Make ethnicity column for treatment number ####
treatment_numbers_white <- treatment_numbers_clean %>%
  mutate(Ethnicity = "White") %>%
  mutate(Value = `Ethnicity_white`) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)

treatment_numbers_mixed <- treatment_numbers_clean %>%
  mutate(Ethnicity = "Mixed") %>%
  mutate(Value = `Ethnicity_mixed`) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)

treatment_numbers_asian <- treatment_numbers_clean %>%
  mutate(Ethnicity = "Asian") %>%
  mutate(Value = `Ethnicity_asian`) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)

treatment_numbers_black <- treatment_numbers_clean %>%
  mutate(Ethnicity = "Black") %>%
  mutate(Value = `Ethnicity_black`) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)

treatment_numbers_other <- treatment_numbers_clean %>%
  mutate(Ethnicity = "Other") %>%
  mutate(Value = `Ethnicity_other`) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)

treatment_numbers_total <- treatment_numbers_clean %>%
  mutate(Ethnicity = "") %>%
  mutate(Value = Total) %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)


treatment_numbers_disaggs <- dplyr::bind_rows(treatment_numbers_total,
                                              treatment_numbers_white,
                                              treatment_numbers_asian,
                                              treatment_numbers_black,
                                              treatment_numbers_other,
                                              treatment_numbers_mixed)


#### Calculating alcohol and non-opiates in treatment number ####
  # For alcohol need to add "Alcohol only" and "Alcohol & non-opiates"
  # For non-opiates need to add "non-opiates only" and "Alcohol & non-opiates"

treatment_alcohol <- treatment_numbers_disaggs %>%
  filter(`Drug group` == "Alcohol only" | 
         `Drug group` == "Alcohol & non-opiates" | 
         `Drug group` == "Non-opiate & alcohol" |
         `Drug group` == "Non-opiates & alcohol") %>%
  group_by(Year, Series, Country, `Local authority`, 
           Sex, Age, Ethnicity, Units) %>%
  summarize(Value = sum(Value)) %>%
  mutate(`Drug group` = "Alcohol") %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)


treatment_opiates <- treatment_numbers_disaggs %>%
  filter(`Drug group` == "Opiates" |`Drug group` ==  "Opiate") %>%
  mutate(`Drug group`= recode(`Drug group`, "Opiates" = "Opiate"))
  
  
treatment_non_opiates <- treatment_numbers_disaggs %>% 
  filter(`Drug group` == "Non-opiate only" | 
         `Drug group` == "Alcohol & non-opiates" | 
         `Drug group` == "Non-opiates only" | 
         `Drug group` == "Non-opiates & alcohol" | 
         `Drug group` == "Non-opiate & alcohol") %>%
  group_by(Year, Series, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units) %>%
  summarize(Value = sum(Value)) %>%
  mutate(`Drug group` = "Non-opiates") %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)


treatment_total <- treatment_numbers_disaggs %>% 
  filter(`Drug group` == "")


#### Bind treatment drug groups ####

treatment_final <- dplyr::bind_rows(treatment_total,
                                    treatment_opiates,
                                    treatment_non_opiates,
                                    treatment_alcohol)


#### Read in estimated prevalence data #### 
alcohol_prevalence_data <- read.csv(paste0(input_folder, "/", alcohol_prevalence)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



#### England as a LA in prevalence data #### 
# alcohol prevalence for England overall is only in the dataset from 2015/16
# Numbers we get doing this are VERY similar to the figure for England (2017/18 is the same, 2015/16 and 2016/7 differs by 3 or 4)
# so remove the years where and England figure is given and use sum of LAs where England figure is not given
England_prevalence_calculation <- alcohol_prevalence_data %>% 
  filter(Local_Authority != "England") %>% 
  group_by(Year) %>% 
  summarise(Alcohol_dependent = sum(Alcohol_dependent)) %>% 
  filter(Year != "2018/19" & Year != "2017/18" & Year != "2016/17" & Year!= "2015/16") %>% 
  mutate(Local_Authority = "England")
# append to data
alcohol_prevalence_all <- alcohol_prevalence_data %>% 
  bind_rows(England_prevalence_calculation)


#### Manipulate alcohol prevalence dataframe ####
alcohol_prevalence_clean <- alcohol_prevalence_all %>% 
  # there is an error in the spreadsheet: the Sheffield report says they provide data from 2010/11 to 2014/15
  # this is presented in the PHE spreadsheet as 2010 - 2014 in the actual tab - correct this here
  mutate(Year = case_when(
    Year == "2010" ~ "2010/11",
    Year == "2011" ~ "2011/12",
    Year == "2012" ~ "2012/13",
    Year == "2013" ~ "2013/14",
    Year == "2014" ~ "2014/15",
    TRUE ~ as.character(Year))) %>% 
  rename(`Local authority` = Local_Authority,
         Value = Alcohol_dependent) %>%
  mutate(`Local authority` = case_when(
    `Local authority` == "England" ~ "", 
    TRUE ~ toTitleCase(`Local authority`))) %>%
  mutate(Ethnicity = "",
         Country = "England",
         Age = "18 and over",
         Sex = "",
         Units = "Number",
         `Drug group` = "Alcohol",
         Series = "Estimated prevalence") %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)
         

#### Check Local Authority names match between datasets ####
alcohol_prevalence_distinct_LAs <- alcohol_prevalence_clean %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_prevalence = TRUE)

alcohol_treatment_distinct_LAs <- treatment_final %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_treatment = TRUE)

alcohol_met_need_distinct_LAs <- met_need_clean %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_met_need = TRUE)


LA_names_check <- alcohol_treatment_distinct_LAs %>% 
  # keep all rows from all datasets
  full_join(alcohol_prevalence_distinct_LAs, by = c("Local authority")) %>%
  full_join(alcohol_met_need_distinct_LAs, by = c("Local authority")) %>% 
  # just keep rows where the LA is not in all datasets
  filter(is.na(dataset_treatment) | is.na(dataset_prevalence))
# for check to pass, there should be no rows remaining with data
LA_names_check_result <- ifelse(nrow(LA_names_check)==0, "LA names match", paste(nrow(LA_names_check), "rows do not match for LA"))
LA_names_check_result


#### Some LA discrepancies to sort out ####

treatment_final <- treatment_final %>% 
  mutate(`Local authority` = case_when(
    `Local authority` == "Durham" ~ "County Durham",
    `Local authority` == "Dorset (Pre April 2019)" ~ "Dorset",
    `Local authority` == "Northamptonshire (Pre April 2022)" ~ "Northamptonshire",
    `Local authority` == "Stockton" ~ "Stockton-on-Tees",
    `Local authority` == "Bristol" ~ "Bristol, City of",
    `Local authority` == "St Helens" ~ "St. Helens",
    `Local authority` == "Kingston upon Hull, City of" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Kingston upon Hull" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Kingston Upon Hull" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Herefordshire" ~ "Herefordshire, County of",
    `Local authority` == "Bedfordshire (to 2011/12)" ~ "Bedfordshire",
    `Local authority` == "Cheshire (to 2011/12)" ~ "Cheshire",
    `Local authority` == "Bournemouth (to 2018/19)" ~ "Bournemouth",
    `Local authority` == "Bournemouth Christchurch and Poole (from 2019/20)" ~ "Bournemouth, Christchurch and Poole",
    `Local authority` == "Bedford (from 2012/13)" ~ "Bedford",
    `Local authority` == "Central Bedfordshire (from 2012/13)" ~ "Central Bedfordshire",
    TRUE ~ as.character(`Local authority`)))

met_need_clean <- met_need_clean %>% 
  mutate(`Local authority` = gsub(" Ua", "", `Local authority`)) %>%
  mutate(`Local authority` = gsub("\\(", "", `Local authority`)) %>%  
  mutate(`Local authority` = gsub("\\)", "", `Local authority`)) %>% 
  mutate(`Local authority` = gsub("Bristol", "Bristol, City of", `Local authority`)) %>%
  mutate(`Local authority` = gsub("Kingston Upon Hull", "Kingston Upon Hull, City of", `Local authority`)) %>%
  mutate(`Local authority` = gsub("Herefordshire", "Herefordshire, County of", `Local authority`)) %>%
  mutate(`Local authority` = gsub(" Cty", "", `Local authority`)) 


#### Rerun Check for Local Authority names match between datasets ####
alcohol_prevalence_distinct_LAs <- alcohol_prevalence_clean %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_prevalence = TRUE)

alcohol_treatment_distinct_LAs <- treatment_final %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_treatment = TRUE)

alcohol_met_need_distinct_LAs <- met_need_clean %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_met_need = TRUE)


LA_names_check <- alcohol_treatment_distinct_LAs %>% 
  # keep all rows from all datasets
  full_join(alcohol_prevalence_distinct_LAs, by = c("Local authority")) %>%
  full_join(alcohol_met_need_distinct_LAs, by = c("Local authority")) %>% 
  # just keep rows where the LA is not in all datasets
  filter(is.na(dataset_treatment) | is.na(dataset_prevalence))
# for check to pass, there should be no rows remaining with data
LA_names_check_result <- ifelse(nrow(LA_names_check)==0, "LA names match", paste(nrow(LA_names_check), "rows do not match for LA"))
LA_names_check_result


# Please note, some cannot be fixed.

#### Calculate alcohol met need from pre 2018/19 ####

# alcohol_prevalence_clean
# treatment_final
# met_need_clean

# Unmet need % from fingertips only goes back to 2018/19.
# therefore calculate prior to this from estimated prevalence 
# number of drinkers in treatment / number estimated to have an alcohol use disorder * 100
# then bind to the fingertips data from 2018/19 onwards

alcohol_met_need <- alcohol_prevalence_clean %>% 
  left_join(treatment_final, by = c("Year", "Local authority", "Sex",
                                    "Ethnicity", "Drug group", "Country")) %>% 
  filter(Age.y == "") %>% # can only do calculation for 18 and over as prevalence data is not age disaggregated.
  mutate(Value = (Value.y / Value.x)*100) %>% 
  rename(Age = Age.x) %>% 
  mutate(Series = "Met need (%)") %>%
  mutate(Units = "Percentage (%)") %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value) 

# no need for country as all England

met_need_final <- dplyr::bind_rows(alcohol_met_need,
                                    met_need_clean)


#### Combine treatment numbers, estimated prevalence and met need % ####

csv_formatted <- dplyr::bind_rows(
  treatment_final,
  met_need_final,
  alcohol_prevalence_clean) %>% 
  select (-Country)


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





