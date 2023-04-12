# Date: 12/04/2023
# Author: Michael Nairn


#### Read in data #### 
England_data <- read.csv(paste0(input_folder, "/", filename_England)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


LA_data <- read.csv(paste0(input_folder, "/", filename_LA)) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### select and rename columns from England data ###

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


#### Select and rename relevant columns from LA data ####

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



#### Bind England and LA data #### 

treatment_numbers <- dplyr::bind_rows(England_clean,
                                      LA_clean)


#### Recode age, sex ####

treatment_numbers_clean <- treatment_numbers %>%
  mutate(Sex = recode(Sex, "Total" = "", "F" = "Female", "M" = "Male")) %>%
  mutate(Age = gsub("\\-", " to ", Age), 
         Age = gsub("\\+", " and over", Age),
         Age = gsub("Total", "", Age),
         Age = str_to_sentence(Age))


#### Add in geography disaggs ####
treatment_numbers_clean <- treatment_numbers_clean %>% 
  mutate(Country = "England") %>%
  mutate('Local authority' = case_when(
    Area == "England" ~ "", 
    TRUE ~ toTitleCase(Area))) %>%
  select(Year, Country, `Local authority`, Sex, Age, drug_group,
         Ethnicity_white, Ethnicity_mixed, Ethnicity_asian, 
         Ethnicity_black, Ethnicity_other, Total)


##############




# import estimates for number of people with disorders
# because of different data availability in the different sources the only disaggregations we can calculate are:
# 1) met need for OCU treatment by age (25-34, 35-64 for 2010 onwards) for England (no LA data)
# 2) met need for opiates treatment by age (25-34, 35-64 for 2010 onwards) for England
# 3) met need for OCU treatment by Local Authority (2018/19 only as for 15-64 - agebands for treatment data dont match for LA data)
# 4) met need for alcohol treatment by Local Authority (18+ for 2010 onwards) - use this to check calcs against data on dashboard

# import prevalence estimates
# OCU_prevalence_by_age <- read.csv('OCU_Estimates_by_age_England_for_R.csv')
# opiate_prevalence_by_age <- read.csv('Opiate_Estimates_by_age_England_for_R.csv')
alcohol_prevalence_by_LA <- read.csv('Input\\Estimates_of_Alcohol_Dependent_Adults_in_England_for_R.csv') %>% 
  # select(-c(X, X.1, X.2)) %>% 
  # there is an error in the spreadsheet: the Sheffield report says they provide data from 2010/11 to 2014/15
  # this is presented in the PHE spreadsheet as 2010 - 2014 in the actual tab - correct this here
  mutate(Year = case_when(
    Year == "2010" ~ "2010/11",
    Year == "2011" ~ "2011/12",
    Year == "2012" ~ "2012/13",
    Year == "2013" ~ "2013/14",
    Year == "2014" ~ "2014/15",
    TRUE ~ as.character(Year))) 




#########################################
#           ---- ALCOHOL ----           #
#########################################

alcohol_category_list_viewit <- c("alcohol only", "alcohol & non-opiates")
alcohol_category_list_phe <- c("Alcohol.only", "Non.opiate.and.alcohol")

# Get alcohol figures for England (PHE table)
# add together the numbers for the different alcohol groups
treatment_data_alcohol_England <- treatment_data %>% 
  filter(Substance %in% alcohol_category_list_phe) %>% 
  group_by(Year) %>% 
  summarise(number_in_treatment = sum(number_in_treatment)) %>% 
  # identify data as being England, for appending to the LA data
  mutate(Area = "England") 

# Get alcohol treatment figures by Local Authority (from ViewIT website)
# headline LA figures (not disaggregated by age or sex)
treatment_data_alcohol_by_LA <- viewit_data_by_LA %>% 
  filter(drug_group %in% alcohol_category_list_viewit &
           gender == "Total" &
           age_group == "Total") %>% 
  mutate(Year = substr(as.character(pend), 7, 10)) %>% 
  mutate(Year = paste(as.numeric(Year)-1, "/", substr(Year, 3, 4), sep = "")) %>%  # pend seems to give the final date of collection (which according to PHE runs 1 April - 31 March)
  rename(Substance = drug_group) %>% 
  # add figures for alcohol groups together
  group_by(Year, Area) %>% 
  summarise(number_in_treatment = sum(InTreatment_AllInTx)) 




# check Local Authority names match between prevalence and treatment datasets (and unmet_need data)
alcohol_prevalence_distinct_LAs <- alcohol_prevalence_by_LA %>% 
  distinct(Local_Authority, Area_Code_GSS) %>% 
  mutate(dataset_prevalence = TRUE)
alcohol_treatment_distinct_LAs <- treatment_data_alcohol_by_LA %>% 
  distinct(Area) %>% 
  mutate(dataset_treatment = TRUE)
alcohol_unmet_need_distinct_LAs <- unmet_need_2018_19 %>% 
  distinct(Area.Name) %>% 
  mutate(dataset_unmet_need = TRUE)

LA_names_check <- alcohol_treatment_distinct_LAs %>% 
  # keep all rows from all datasets
  full_join(alcohol_prevalence_distinct_LAs, by = c("Area" = "Local_Authority")) %>% 
  full_join(alcohol_unmet_need_distinct_LAs, by = c("Area" = "Area.Name")) %>% 
  # just keep rows where the LA is not in all datasets
  filter(is.na(dataset_treatment) | is.na(dataset_prevalence))
# for check to pass, there should be no rows remaining with data
LA_names_check_result <- ifelse(nrow(LA_names_check)==0, "LA names match", paste(nrow(LA_names_check), "rows do not match for LA"))
LA_names_check_result

# there are some mismatches - so look at LA_names_check to identify issues and fix:
treatment_data_alcohol_by_LA <- treatment_data_alcohol_by_LA %>% 
  mutate(Area = as.character(Area)) %>% 
  mutate(Area = case_when(
    Area == "Durham" ~ "County Durham",
    Area == "Stockton" ~ "Stockton-on-Tees",
    Area == "St Helens" ~ "St. Helens",
    Area == "Kingston upon Hull" ~ "Kingston upon Hull, City of",
    Area == "Herefordshire" ~ "Herefordshire, County of",
    Area == "Bristol" ~ "Bristol, City of",
    TRUE ~ as.character(Area) # this catches the remainder that need to stay as they were (without this line they will become NAs)
  ))
unmet_need_alcohol_by_LA <- unmet_need_2018_19 %>% 
  mutate(Area.Name = as.character(Area.Name)) %>% 
  mutate(Area.Name = case_when(
    Area.Name == "Durham" ~ "County Durham",
    Area.Name == "Stockton" ~ "Stockton-on-Tees",
    Area.Name == "St Helens" ~ "St. Helens",
    Area.Name == "Kingston upon Hull" ~ "Kingston upon Hull, City of",
    Area.Name == "Herefordshire" ~ "Herefordshire, County of",
    Area.Name == "Bristol" ~ "Bristol, City of",
    TRUE ~ as.character(Area.Name) # this catches the remainder that need to stay as they were (without this line they will become NAs)
  ))
# there are a few that can't be fixed:
# Cheshire (Discontinued), Bedfordshire (Discontinued), Cornwall

# re-run check (don't care much about the unmet need data as that is just for a check)
alcohol_treatment_distinct_LAs <- treatment_data_alcohol_by_LA %>% 
  distinct(Area) %>% 
  mutate(dataset_treatment = TRUE)
LA_names_check <- alcohol_treatment_distinct_LAs %>% 
  full_join(alcohol_prevalence_distinct_LAs, by = c("Area" = "Local_Authority")) %>% 
  # just keep rows where the LA is in onky ine dataset or the other, not both
  filter(is.na(dataset_treatment) | is.na(dataset_prevalence))
# for check to pass, there should be no rows remaining with data
LA_names_check_result <- ifelse(nrow(LA_names_check)==3, "LA names match", paste(3 - nrow(LA_names_check), "rows do not match for LA"))
LA_names_check_result

# alcohol prevalence for England overall is only in the dataset from 2015/16
# Numbers we get doing this are VERY similar to the figure for England (2017/18 is the same, 2015/16 and 2016/7 differs by 3 or 4)
# so remove the years where and England figure is given and use sum of LAs where England figure is not given
England_prevalence_calculation <- alcohol_prevalence_by_LA %>% 
  filter(Local_Authority != "England") %>% 
  group_by(Year) %>% 
  summarise(Alcohol_dependent = sum(Alcohol_dependent)) %>% 
  filter(Year != "2018/19" & Year != "2017/18" & Year != "2016/17") %>% 
  mutate(Local_Authority = "England")
# append to data
alcohol_prevalence_all <- alcohol_prevalence_by_LA %>% 
  bind_rows(England_prevalence_calculation)

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



alcohol_PHE_met_need <- unmet_need_alcohol_by_LA %>% 
  filter(Indicator.Name == "Proportion of dependent drinkers not in treatment (%) (Current method)",
         Category == "") %>% 
  mutate(Time.period = as.character(Time.period)) %>% 
  rename(Year = Time.period,
         Area_Code_GSS = Area.Code,
         Local_Authority = Area.Name,
         Alcohol_dependent = Denominator) %>% 
  mutate(number_in_treatment = Alcohol_dependent - Count) %>% 
  mutate(met_need = 100 - Value) %>% 
  select(Year, Area_Code_GSS, Local_Authority, met_need, number_in_treatment, Alcohol_dependent)


alcohol_all_calcs <- alcohol_PHE_met_need %>% 
  bind_rows(alcohol_met_need) %>% 
  mutate(year_numeric = as.numeric(substr(Year, 1, 4)))

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

# Format for csv file
alcohol_met_need_for_csv <- alcohol_all_calcs %>% 
  select(Year, Area_Code_GSS, Local_Authority, met_need) %>% 
  mutate(Units = "Met need (%)",
         `Unit measure` = "Percentage (%)") %>% 
  rename(Value = met_need)
alcohol_in_treatment_for_csv <- alcohol_all_calcs %>% 
  select(Year, Area_Code_GSS, Local_Authority, number_in_treatment) %>% 
  mutate(Units = "Number of people in treatment",
         `Unit measure` = "Count") %>% 
  rename(Value = number_in_treatment)
alcohol_prevalence_for_csv <- alcohol_all_calcs %>% 
  select(Year, Area_Code_GSS, Local_Authority, Alcohol_dependent) %>% 
  mutate(Units = "Estimated prevalence",
         `Unit measure` = "Number") %>% 
  rename(Value = Alcohol_dependent)
alcohol_for_csv <- bind_rows(alcohol_met_need_for_csv,
                             alcohol_in_treatment_for_csv,
                             alcohol_prevalence_for_csv) %>% 
  mutate(Substance = "Alcohol",
         `Unit multiplier` = "Units") %>% 
  # reorder columns
  select(Year, Units, Local_Authority, Substance, `Unit multiplier`, `Unit measure`, Value) %>% 
  # make England blank
  mutate(Local_Authority = ifelse(Local_Authority == "England", "", Local_Authority))

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
