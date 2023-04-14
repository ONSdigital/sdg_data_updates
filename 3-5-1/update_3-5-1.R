# Date: 12/04/2023
# Author: Michael Nairn


#### Read in treatment numbers data #### 
England_data <- read.csv(paste0(input_folder, "/", filename_England)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


LA_data <- read.csv(paste0(input_folder, "/", filename_LA)) %>% 
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
         `Drug group` == "Alcohol & non-opiates") %>%
  mutate(`Drug group` = "Alcohol") %>%
  group_by(Year, Series, `Drug group`, Country, `Local authority`, 
           Sex, Age, Ethnicity, Units) %>%
  summarize(Value = sum(Value))


treatment_opiates <- treatment_numbers_disaggs %>%
  filter(`Drug group` == "Opiates")
  
  
treatment_non_opiates <- treatment_numbers_disaggs %>% 
  filter(`Drug group` == "Non-opiates only" | 
         `Drug group` == "Alcohol & non-opiates") %>%
  mutate(`Drug group` = "Non-opiates") %>% 
  group_by(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units) %>%
  summarize(Value = sum(Value))

treatment_total <- treatment_numbers_disaggs %>% 
  filter(`Drug group` == "")



#### Calculate met need from pre 2018/19 ####

# Unmet need % from fingertips only goes back to 2018/19.
  # therefore calculate prior to this from estimated prevalence 

#### Read in estimated prevalence data #### 
alcohol_prevalence_data <- read.csv(paste0(input_folder, "/", alcohol_prevalence)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Manipulate alcohol prevalence dataframe ####
alcohol_prevalence_clean <- alcohol_prevalence_data %>% 
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
  mutate(`Local authority` = toTitleCase(`Local authority`)) %>%
  mutate(Ethnicity = "",
         Country = "England",
         Age = "18 and over",
         Sex = "",
         Units = "Number",
         `Drug group` = "Alcohol",
         Series = "Estimated prevalence") %>%
  select(Year, Series, `Drug group`, Country, `Local authority`, 
         Sex, Age, Ethnicity, Units, Value)
         
  
#### Combine treatment numbers, estimated prevalence and met need % ####

treatment_prevalence_and_met_need <- dplyr::bind_rows(treatment_total,
                                           treatment_opiates,
                                           treatment_non_opiates,
                                           treatment_alcohol,
                                           met_need_clean,
                                           alcohol_prevalence_clean)


#### Some LA discrepancies to sort out ####

treatment_prevalence_and_met_need <- treatment_prevalence_and_met_need %>% 
  mutate(`Local authority` = case_when(
    `Local authority` == "Durham" ~ "County Durham",
    `Local authority` == "Stockton" ~ "Stockton-on-Tees",
    `Local authority` == "St Helens" ~ "St. Helens",
    `Local authority` == "Kingston upon Hull, City of" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Kingston upon Hull" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Kingston Upon Hull" ~ "Kingston Upon Hull, City of",
    `Local authority` == "Herefordshire" ~ "Herefordshire, County of",
    `Local authority` == "Bedfordshire (to 2011/12)" ~ "Bedfordshire (Discontinued)",
    `Local authority` == "Cheshire (to 2011/12)" ~ "Cheshire (Discontinued)",
    `Local authority` == "Bournemouth (to 2018/19)" ~ "Bournemouth (Discontinued)",
    `Local authority` == "Bournemouth Christchurch and Poole (from 2019/20)" ~ "Bournemouth, Christchurch and Poole (from 2019/20)",
    `Local authority` == "Bedford (from 2012/13)" ~ "Bedford",
    `Local authority` == "Central Bedfordshire (from 2012/13)" ~ "Central Bedfordshire",
    TRUE ~ as.character(`Local authority`)))

treatment_prevalence_and_met_need <- treatment_prevalence_and_met_need %>% 
  mutate(`Local authority` = gsub(" Ua", "", `Local authority`)) %>%
  mutate(`Local authority` = gsub("\\(", "", `Local authority`)) %>%  
  mutate(`Local authority` = gsub("\\)", "", `Local authority`)) %>% 
  mutate(`Local authority` = gsub(" Cty", "", `Local authority`)) 


# check Local Authority names match between prevalence and treatment datasets (and unmet_need data)
distinct_LAs <- treatment_prevalence_and_met_need %>% 
  distinct(`Local authority`) %>% 
  mutate(dataset_prevalence = TRUE)


# calculate met need for alcohol
# number of drinkers in treatment / number estimated to have an alcohol use disorder * 100

if(LA_names_check_result == "LA names match"){
  
  years_available <- unique(c(unique(alcohol_prevalence_all$Year), unique(treatment_data_alcohol_by_LA$Year)))
  
  alcohol_met_need <- alcohol_prevalence_all %>% 
    full_join(treatment_data_alcohol_by_LA, by = c("Local_Authority" = "Area", "Year")) %>% 
    # remove years where we don't have data for both numerator and denominator
    filter(Year %in% years_available) %>% 
    mutate(met_need = (number_in_treatment / Alcohol_dependent)*100) # CIs are not symmetrical, so the way Martin said to calculate CIs can't be right...
  
}else{print(paste("alcohol met need by LA not calculated because", LA_names_check_result))}

# check that my numbers are not weird compared to the published PHE figures for 2018/19 (treatment numbers by LA not available for 2018/19 so can't check exact match)
# make sure LA names in unmet_need data match 





LA_list <- unique(alcohol_all_calcs$Local_Authority)


# the counts from the fingertips website must be number NOT in treatment
# when you then calculate number IN treatment (denominator - count), they quite don't match the numbers from the ViewIt website
# out by a maximum of 4 - ask PHE why this is.

unmet_need_calc_in_treatment <- alcohol_PHE_met_need %>% 
  rename(calc_in_treatment = number_in_treatment) %>% 
  select(Local_Authority, calc_in_treatment)
unmet_need_count_check <- treatment_data_alcohol_by_LA %>% 
  filter(Year == "2018/19") %>% 
  full_join(unmet_need_calc_in_treatment, by = c("Area" = "Local_Authority")) %>% 
  mutate(difference = number_in_treatment - calc_in_treatment)

# check the sum of LA prevalence == England prevalence: very close to a match (out by max 4)
prevalence_sum_of_LAs_check <- alcohol_prevalence_by_LA %>% 
  filter(Local_Authority != "England") %>% 
  group_by(Year) %>% 
  summarise(England_estimate = sum(Alcohol_dependent)) %>%
  mutate(Local_Authority = "England") %>% 
  left_join(alcohol_prevalence_by_LA, by = c("Year", "Local_Authority"))


# investigate NA values and remove them if they should be removed
alcohol_NAs <- alcohol_for_csv %>% 
  filter(is.na(Value)) %>% 
  # no prevalence data for 2009/10 (dates are wrong on spreadsheet), or any years before then.
  # NAs will be given to prevalence on rows created for treatment in 2018/19
  filter(Year %!in% c("2009/10", "2008/09", "2007/08", "2006/07", "2005/06", "2018/19")) %>% 
  # In 2010/11 treatment figs are given for Bedfordshire (discontinued) and Cheshire (discontinued), but not for their component LAs
  # however, prevalence is only given for the component LAs
  filter(Local_Authority %!in% c("Cheshire East", "Cheshire West and Chester", "Cheshire (Discontinued)",
                                 "Bedford", "Central Bedfordshire", "Bedfordshire (Discontinued)")) %>% 
  # In 2017/18 and 2018/19 prevalence seem to only have been calculated for Cornwall, while treatment figures are 
  # for Cornwall & Isles of Scilly. The 2018/19 prevalence estimate is treated as though it is for Cornwall & Isles of Scilly
  # as Prevalence (Denominator) minus Count equals the treatment figures for Cornwall & Isles of Scilly.
  # For now drop Cornwall-only estimates but after checking with PHE I might need to add them in and join them to Cornwall & IoS treatment figures.
  filter(Local_Authority %!in% c("Cornwall", "Cornwall & Isles of Scilly"))

# All NA rows can be removed (for reasons why see previous block)  
alcohol_for_csv_final <- alcohol_for_csv %>% 
  filter(!is.na(Value)) %>% 
  filter(Year %!in% c("2009/10", "2008/09", "2007/08", "2006/07", "2005/06")) %>% 
  filter(Local_Authority != "Cornwall")
