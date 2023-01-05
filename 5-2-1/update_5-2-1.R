# author: Michael Nairn
# date: 05/11/2023

# Indicator 5-2-1 uses multiple tabs from the Domestic abuse prevalence and 
  # victim characteristics dataset fromt he Crime Survery for ENgland and Wales.
  # https://www.ons.gov.uk/peoplepopulationandcommunity/crimeandjustice/datasets/domesticabuseprevalenceandvictimcharacteristicsappendixtables


# These will need processing separately and then bound.
  # Note that only data for women is needed.


#### Read in data and select relevant columns ####

# Abuse type for 16 years and over by type of abuse and sex
AbuseType_16plus <- read_excel(paste0(input_folder, "/", filename),
                                     sheet = tabname1, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), toupper)) %>% 
  select(all_of(c("Type of abuse [note 4]",
                  "Women in the last year"))) %>%
  rename(`Type of abuse` = `Type of abuse [note 4]`,
         Value = `Women in the last year`) %>%
  mutate(Age = "16 and over")
                  

# Abuse type for aged 16 to 59 years by type of abuse and sex
AbuseType_16to59 <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname3, skip = 6, col_names = FALSE) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), toupper)) %>%
  filter(...2 == "WOMEN") %>%
  select(all_of(c(1, 19))) %>% 
  mutate(Age = "16 to 59")
    
colnames(AbuseType_16to59) <- c("Type of abuse", "Value", "Age")


# Abuse type for 16 years and over by type of personal characteristics and sex
# need to only include "by a partner", column "Any partner abuse Women"

Personal_Char_16plus <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname6, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), toupper)) %>% 
  select(all_of(c(2, 7))) %>% 
  mutate(Age = "")

colnames(Personal_Char_16plus) <- c("Characteristics", "Value", "Age")


# Abuse type for 16 years and over by type of household characteristics and sex
# need to only include "by a partner", column "Any partner abuse Women"
Household_Char_16plus <- read_excel(paste0(input_folder, "/", filename),
                               sheet = tabname7, skip = 6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), toupper)) %>%
  select(all_of(c(2, 7))) %>% 
  mutate(Age = "")

colnames(Household_Char_16plus) <- c("Characteristics", "Value", "Age")


#### Bind together and join dataframes ####

Abuse_type <- rbind(AbuseType_16to59, AbuseType_16plus) %>%
  mutate(Characteristics = "") %>%
  select(all_of(c("Type of abuse",
                  "Age",
                  "Characteristics",
                  "Value")))


Characteristics <- rbind(Personal_Char_16plus, Household_Char_16plus) %>%
  mutate(`Type of abuse` = "") %>%
  select(all_of(c("Type of abuse",
                  "Age",
                  "Characteristics",
                  "Value")))


Abuse <- rbind(Abuse_type, Characteristics) %>% 
  rename(`Type of partner abuse` = `Type of abuse`)


#### Remove unnecessary rows ####

# need to only include "by a partner",



#### sub-categorise type of abuse into non-sexual, sexual, stalking ####



#### Split out characteristics ####








