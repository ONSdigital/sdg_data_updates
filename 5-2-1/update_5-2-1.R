# author: Michael Nairn
# date: 05/11/2023

# Indicator 5-2-1 uses multiple tabs from the Domestic abuse prevalence and 
  # victim characteristics dataset fromt he Crime Survery for ENgland and Wales.
  # https://www.ons.gov.uk/peoplepopulationandcommunity/crimeandjustice/datasets/domesticabuseprevalenceandvictimcharacteristicsappendixtables


# Note that only data for women is needed.


#### Read in data and select relevant columns ####

# Abuse type for 16 years and over by type of abuse and sex
AbuseType_16plus <- read_excel(paste0(input_folder, "/", filename),
                                     sheet = tabname1, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  select(all_of(c("Type of abuse [note 4]",
                  "Women in the last year"))) %>%
  rename(`Type of abuse` = `Type of abuse [note 4]`,
         Value = `Women in the last year`) %>%
  mutate(Series = "Women aged 16 and over (%)")
                  

# Abuse type for aged 16 to 59 years by type of abuse and sex
AbuseType_16to59 <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname3, skip = 6, col_names = FALSE) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  filter(...2 == "Women") %>%
  select(all_of(c(1, 19))) %>% 
  mutate(Series = "Women aged 16 to 59 (%)")
    
colnames(AbuseType_16to59) <- c("Type of abuse", "Value", "Series")


# Abuse type for 16 years and over by type of personal characteristics and sex
# need to only include "by a partner", column "Any partner abuse Women"

Personal_Char_16plus <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname6, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  select(all_of(c(2, 7))) %>% 
  mutate(Series = "Women aged 16 and over (%)")

colnames(Personal_Char_16plus) <- c("Characteristics", "Value", "Series")


# Abuse type for 16 years and over by type of household characteristics and sex
# need to only include "by a partner", column "Any partner abuse Women"
Household_Char_16plus <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname7, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  select(all_of(c(2, 7))) %>% 
  mutate(Series = "Women aged 16 and over (%)")

colnames(Household_Char_16plus) <- c("Characteristics", "Value", "Series")


#### Bind together and join dataframes ####

Abuse_type <- rbind(AbuseType_16to59, AbuseType_16plus) %>%
  mutate(Characteristics = "") %>%
  select(all_of(c("Type of abuse",
                  "Series",
                  "Characteristics",
                  "Value")))


Characteristics <- rbind(Personal_Char_16plus, Household_Char_16plus) %>%
  mutate(`Type of abuse` = "") %>%
  select(all_of(c("Type of abuse",
                  "Series",
                  "Characteristics",
                  "Value")))


Abuse <- rbind(Abuse_type, Characteristics) %>% 
  mutate(Year = "2021/22") %>% 
  mutate(Units = "Percentage (%)") %>% 
  mutate(`Unit multiplier` = "Units") %>%
  mutate(`Observation status` = case_when(
    Value == "[c]" ~ "Missing value; suppressed", 
    TRUE ~ "Normal value"))


#### Remove unnecessary rows ####

# need to only include "by a partner",
  # due to duplication of abuse sub-categories (e.g. Threats) 
  # across partner abuse and family abuse we can't use string detection functions. 
  # Have just called rows by indexing. This is not ideal

#   REVIEWER - DO YOU HAVE A BETTER SOLUTION?

P_Abuse <- Abuse[c(2, 4:8, 14:16, 24, 28, 35:39, 50:52, 61, 65:124, 126:169),]



#### Sub=categorise abuse types ####
  # Type of partner abuse into non-sexual, sexual, stalking
  # Then all sub-categories within these to be in "Abuse sub-category"

Partner_abuse <- P_Abuse %>% 
  mutate(
    `Type of partner abuse` = case_when(
      `Type of abuse` == "Any partner abuse (non-physical abuse, threats, force, sexual assault or stalking)" ~ "Total",
      `Type of abuse` == "Any sexual assault (including attempts) by a partner" ~ "Sexual (including attempts)",
      `Type of abuse` == "Partner abuse - non-sexual" ~ "Non-sexual",
      `Type of abuse` == "Stalking by a partner or ex-partner" ~ "Stalking by a partner/ex-partner",
      `Type of abuse` == "Sexual assault by rape or penetration (including attempts) by a partner" ~ "Sexual (including attempts)",
      `Type of abuse` == "Indecent exposure or unwanted sexual touching by a partner" ~ "Sexual (including attempts)",
      `Type of abuse` == "Non-physical abuse (emotional, financial)" ~ "Non-sexual",
      `Type of abuse` == "Threats or force" ~ "Non-sexual",
      `Type of abuse` == "Threats" ~ "Non-sexual",
      `Type of abuse` == "Force" ~ "Non-sexual",
      TRUE ~ ""),
    `Abuse sub-category` = case_when(
      `Type of partner abuse` ==  "Sexual (including attempts)" ~ `Type of abuse`,
      `Type of partner abuse` ==  "Non-sexual" ~ `Type of abuse`,
      TRUE ~ ""))



#### Split out characteristics ####

# for future iterations be careful here as new disaggregations may be added,
  # or existing ones changed.
  # For example, the boundaries for household income change regularly.

# Age disaggregation
Abuse_age_disagg <- Partner_abuse %>%
  mutate(Age = case_when(
    Characteristics == "75+" ~ Characteristics,
    Characteristics == "16-19" ~ Characteristics,
    Characteristics == "20-24" ~ Characteristics,
    Characteristics == "25-34" ~ Characteristics,
    Characteristics == "35-44" ~ Characteristics,
    Characteristics == "45-54" ~ Characteristics,
    Characteristics == "55-59" ~ Characteristics,
    Characteristics == "60-74" ~ Characteristics,
    TRUE ~ ""))

# NOTE FOR REVIEWER:
  # must be a better way of doing this using REGEX. Useful for many indicators. 
    # [0-9][0-9]"\\-"[0-9][0-9] should pick up all age bands

Abuse_age_disagg$Age = gsub("\\-", " to ", Abuse_age_disagg$Age)
Abuse_age_disagg$Age = gsub("\\+", " and over", Abuse_age_disagg$Age) 

  

# Ethnicity and ethnic group disaggregation

Ethnicity_disagg <- Abuse_age_disagg %>%
  mutate(
  Ethnicity = case_when(
    Characteristics == "White" ~ Characteristics, 
    Characteristics == "Mixed" ~ Characteristics, 
    Characteristics == "Asian or Asian British" ~ Characteristics,
    Characteristics == "Black or Black British" ~ Characteristics, 
    Characteristics == "Other ethnic group" ~ Characteristics,
    TRUE ~ ""))


# Country of birth disaggregation 

Born_disagg <- Ethnicity_disagg %>%
  mutate(
    `Country of birth` = case_when(
      Characteristics == "Born in the UK" ~ Characteristics, 
      Characteristics == "Not born in the UK" ~ Characteristics,
      TRUE ~ ""))


# Marital status disaggregation 

Marital_disagg <- Born_disagg %>%
  mutate(
    `Marital status` = case_when(
      Characteristics == "Married/civil partnered" ~ Characteristics, 
      Characteristics == "Cohabiting" ~ Characteristics,
      Characteristics == "Single" ~ Characteristics, 
      Characteristics == "Separated" ~ Characteristics,
      Characteristics == "Divorced/legally dissolved partnership" ~ Characteristics, 
      Characteristics == "Widowed" ~ Characteristics,
      TRUE ~ ""))


# Employment status disaggregation 

Employment_disagg <- Marital_disagg %>%
  mutate(
    `Employment status` = case_when(
      Characteristics == "In employment" ~ Characteristics, 
      Characteristics == "Unemployed" ~ Characteristics,
      Characteristics == "Economically inactive" ~ Characteristics, 
      Characteristics == "Student" ~ Characteristics,
      Characteristics == "Looking after family/home" ~ Characteristics, 
      Characteristics == "Long-term/temporarily sick/ill" ~ Characteristics,
      Characteristics == "Retired" ~ Characteristics, 
      Characteristics == "Other inactive" ~ Characteristics,
      TRUE ~ ""))


# Occupation status disaggregation 

Occupation_disagg <- Employment_disagg %>%
  mutate(
    `Occupation type` = case_when(
      Characteristics == "Managerial and professional occupations" ~ Characteristics, 
      Characteristics == "Intermediate occupations" ~ Characteristics,
      Characteristics == "Routine and manual occupations" ~ Characteristics, 
      Characteristics == "Never worked and long-term unemployed" ~ Characteristics,
      Characteristics == "Full-time students" ~ Characteristics, 
      Characteristics == "Not classified" ~ Characteristics,
      TRUE ~ ""))


# Highest qualification disaggregation 

Qualification_disagg <- Occupation_disagg %>%
  mutate(
    `Highest qualification` = case_when(
      Characteristics == "Degree or diploma" ~ Characteristics, 
      Characteristics == "Apprenticeship or A/AS level" ~ Characteristics,
      Characteristics == "O level/GCSE" ~ Characteristics, 
      Characteristics == "Other" ~ Characteristics,
      Characteristics == "None" ~ Characteristics, 
      TRUE ~ ""))

# disability status

Disability_disagg <- Qualification_disagg %>%
  mutate(
    `Disability status` = case_when(
      Characteristics == "Disabled" ~ Characteristics, 
      Characteristics == "Not disabled" ~ Characteristics,
      TRUE ~ ""))


# religion status

Religion_disagg <- Disability_disagg %>%
  mutate(
    `Religion` = case_when(
      Characteristics == "Buddhist" ~ Characteristics,
      Characteristics == "Christian" ~ Characteristics,
      Characteristics == "Hindu" ~ Characteristics,
      Characteristics == "Muslim" ~ Characteristics, 
      Characteristics == "Other" ~ Characteristics,
      Characteristics == "No religion" ~ Characteristics, 
      TRUE ~ ""))


# sexual orientation

Orientation_disagg <- Religion_disagg %>%
  mutate(
    `Sexual orientation` = case_when(
      Characteristics == "Heterosexual/straight" ~ Characteristics,
      Characteristics == "Gay/Lesbian" ~ Characteristics,
      Characteristics == "Bisexual" ~ Characteristics,
      Characteristics == "Other" ~ Characteristics,
      TRUE ~ ""))


# gender identity

Gender_identity_disagg <- Orientation_disagg %>%
  mutate(
    `Gender identity` = case_when(
      Characteristics == "Cisgender" ~ Characteristics,
      Characteristics == "Transgender" ~ Characteristics,
      TRUE ~ ""))


# household income

Income_disagg <- Gender_identity_disagg %>%
  mutate(
    `Household income` = case_when(
      Characteristics == "Less than £10,400" ~ Characteristics,
      Characteristics == "£10,400 to less than £20,800" ~ Characteristics,
      Characteristics == "£20,800 to less than £31,200" ~ Characteristics,
      Characteristics == "£31,200 to less than £41,600" ~ Characteristics, 
      Characteristics == "£41,600 to less than £52,000" ~ Characteristics,
      Characteristics == "£52,000 or more" ~ Characteristics, 
      Characteristics == "No income stated or not enough information provided" ~ Characteristics, 
      TRUE ~ ""))


# household tenure 

Tenure_disagg <- Income_disagg %>%
  mutate(
    `Household tenure` = case_when(
      Characteristics == "Owners" ~ Characteristics,
      Characteristics == "Social renters" ~ Characteristics,
      Characteristics == "Private renters" ~ Characteristics,
      TRUE ~ ""))


# accommodation type

Accommodation_disagg <- Tenure_disagg %>%
  mutate(
    `Accommodation type` = case_when(
      Characteristics == "Houses" ~ Characteristics,
      Characteristics == "Detached" ~ Characteristics,
      Characteristics == "Semi-detached" ~ Characteristics,
      Characteristics == "Terraced" ~ Characteristics,
      Characteristics == "Flats/maisonettes" ~ Characteristics,
      Characteristics == "Other" ~ Characteristics,
      TRUE ~ ""))


# output area classification

Area_disagg <- Accommodation_disagg %>%
  mutate(
    `Output area classification` = case_when(
      Characteristics == "Rural residents" ~ Characteristics,
      Characteristics == "Cosmopolitans" ~ Characteristics,
      Characteristics == "Ethnicity central" ~ Characteristics,
      Characteristics == "Multicultural metropolitans" ~ Characteristics,
      Characteristics == "Urbanites" ~ Characteristics,
      Characteristics == "Suburbanites" ~ Characteristics,
      Characteristics == "Constrained city dwellers" ~ Characteristics,
      Characteristics == "Hard-pressed living" ~ Characteristics,
      TRUE ~ ""))


# urban/rural

Urban_rural_disagg <- Area_disagg %>%
  mutate(
    `Urban or rural` = case_when(
      Characteristics == "Urban" ~ Characteristics,
      Characteristics == "Rural" ~ Characteristics,
      TRUE ~ ""))



# country and region

Region_disagg <- Urban_rural_disagg %>%
  mutate(
    Country = case_when(
      Characteristics == "Wales" ~ Characteristics, 
      Characteristics == "North East" ~ "England", 
      Characteristics == "North West" ~ "England", 
      Characteristics == "Yorkshire and the Humber" ~ "England", 
      Characteristics == "East Midlands" ~ "England", 
      Characteristics == "West Midlands" ~ "England", 
      Characteristics == "East" ~ "England", 
      Characteristics == "London" ~ "England", 
      Characteristics == "South East" ~ "England",
      Characteristics == "South West" ~ "England",
      TRUE ~ ""),
    Region = case_when(
      Country == "England" ~ Characteristics,
      TRUE ~ ""))


# Unwanted disaggs 

Other_disagg <- Region_disagg %>%
  mutate(
    Other = case_when(
      Characteristics == "Less than 3 hours" ~ Characteristics,
      Characteristics == "3 hours or more but less than 7 hours" ~ Characteristics,
      Characteristics == "7 hours or longer" ~ Characteristics,
      Characteristics == "Less than once a week" ~ Characteristics,
      Characteristics == "Once a week or more often" ~ Characteristics,
      Characteristics == "Single adult and child(ren)" ~ Characteristics,
      Characteristics == "Adults and child(ren)" ~ Characteristics,
      Characteristics == "Adult(s) and no child(ren)" ~ Characteristics,
      Characteristics == "High" ~ Characteristics,
      Characteristics == "Not high" ~ Characteristics,
      Characteristics == "20% most deprived Output Areas" ~ Characteristics,
      Characteristics == "Other Output Areas" ~ Characteristics,
      Characteristics == "20% least deprived Output Areas" ~ Characteristics,
      TRUE ~ ""))


# need to correct the "other" as it falls into multiple disaggregations.
  # Same for "None" - falls into two.

# NOTE FOR REVIEWER: 
  # Any idea?



All_disaggs <- Other_disagg %>%
  mutate(`Ethnic group` = "")


Disaggs <- subset(All_disaggs, Other == "")


#### Select and order relevant columns ####

csv_prep <- Disaggs %>% 
  # Put columns in order required for csv file.
  select(Year, Series, `Type of partner abuse`, `Abuse sub-category`,
         Age, Ethnicity, `Ethnic group`, `Disability status`, `Country of birth`,
         `Sexual orientation`, `Gender identity`, Religion, `Marital status`,
         `Employment status`, `Occupation type`,
         `Highest qualification`, `Household income`, `Household tenure`, `Accommodation type`,
         `Output area classification`, `Urban or rural`, Country, Region, 
         `Observation status`, Units, `Unit multiplier`, Value) %>%
  # Arrange data by Year, Country, region, Sex 
    arrange(Year, Series, `Type of partner abuse`, `Abuse sub-category`,
            Age, Ethnicity, `Ethnic group`, `Disability status`, `Country of birth`,
            `Sexual orientation`, `Gender identity`, Religion, `Marital status`,
            `Employment status`, `Occupation type`,
            `Highest qualification`, `Household income`, `Household tenure`, `Accommodation type`,
            `Output area classification`, `Urban or rural`, Country, Region)

?arrange
#### Final formatting adjustments ####

# Remove  Unweighted base - number of adults rows
csv_formatted <- csv_prep[!grepl("Unweighted base", csv_prep$`Type of partner abuse`),]


# Correct spelling of Yorkshire and The Humber
csv_formatted$Region[csv_formatted$Region == "Yorkshire and the Humber"] <- "Yorkshire and The Humber"


# Remove total figures from Type of partner abuse and Abuse sub-category columns
csv_formatted$`Type of partner abuse`[csv_formatted$`Type of partner abuse` == "Total"] <- ""
csv_formatted$`Abuse sub-category`[csv_formatted$`Abuse sub-category` == "Partner abuse - non-sexual"] <- ""
csv_formatted$`Abuse sub-category`[csv_formatted$`Abuse sub-category` == "Any sexual assault (including attempts) by a partner"] <- ""



# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)


# If false you may need to remove duplicate rows. 
csv_output <- unique(csv_formatted)

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_output)) == nrow(csv_output)







