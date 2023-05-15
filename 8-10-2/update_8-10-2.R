# author: Katie Uzzell
# date: 25/04/2023

# Code to automate data update for indicator 8-10-2 (Percentage of adults (16 years 
# and older) with an account at a bank or other financial institution).

# read and format in data

savings_investments_data <- get_type1_data(header_row, filename, tabname)

savings_investments_main_data <- extract_data(savings_investments_data, header_row)

savings_investments_main_data <- savings_investments_main_data %>% 
  drop_na("Type of savings and investments")

# split data and format

all_adults_data <- savings_investments_main_data[c(2:21),]

male_data <- savings_investments_main_data[c(24:43),]

female_data <- savings_investments_main_data[c(46:65),]

all_adults_data <- all_adults_data %>% 
  pivot_longer(-c("Type of savings and investments"), names_to = "Age", values_to = "Value")

male_data <- male_data %>% 
  pivot_longer(-c("Type of savings and investments"), names_to = "Age", values_to = "Value")

female_data <- female_data %>% 
  pivot_longer(-c("Type of savings and investments"), names_to = "Age", values_to = "Value")

all_adults_data <- all_adults_data %>% 
  mutate(Sex = "")

male_data <- male_data %>%  
  mutate(Sex = "Male")

female_data <- female_data %>% 
  mutate(Sex = "Female")

# join data and format 

joined_data <- rbind(all_adults_data,
                     male_data,
                     female_data)

joined_data["Value"][joined_data["Value"] == '-'] <- '0'

joined_data["Age"][joined_data["Age"] == 'All Adults'] <- ''

names(joined_data)[names(joined_data) == 'Type of savings and investments'] <- 'Bank account category'

csv_formatted <- joined_data %>% 
         mutate("Series" = "Proportion of adults (15 years and older) with an account at a financial institution or mobile-money-service provider",
           "Unit measure" = "Percentage (%)",
            "Unit multiplier" =  "Units",
            "Observation status" = "Normal value",
            "Year" = year)

csv_formatted$`Bank account category`[csv_formatted$`Bank account category` == "Any other type of asset [Note 7]"] <- "Any other type of asset"
csv_formatted$Age[csv_formatted$Age == "All adults"] <- ""
csv_formatted$Age[csv_formatted$Age == "85+"] <- "85 and over"

csv_formatted <- csv_formatted[order(csv_formatted$"Bank account category"),]

# output csv

csv_output <- csv_formatted %>%            
select("Year", "Series", "Bank account category", "Sex", "Age", "Unit measure", "Unit multiplier", "Observation status", "Value")







