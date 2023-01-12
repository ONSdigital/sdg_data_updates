# author: Ali Campbell
# date: 03/01/2023
# read-in 2022 data disaggregated by age

# AGE
# Reads in age tab of spreadsheet and formats across columns
age_source_data <- read_excel(paste0(input_folder, "/", filename),
                              sheet = tabname_age, skip = header_row_age -1) %>% 
  mutate(across(where(is.factor), as.character))

# Trim source data into a smaller dataframe
age_source_data_sml <- age_source_data %>% 
  slice(1:14) %>% # selects rows 1 to 14
  drop_na("Main method in use") %>% # drops rows where main method in use is NA
  select(!"...2") %>% # selects everything but the ...2 column
  rename(`Total` = `All ages 2`)  # renames the column


# creates a new dataframe with separate columns for main method of and type of contraception
age_data_split <- age_source_data_sml %>%  
  mutate(`Main method of contraception` = case_when(
    `Main method in use` == "Larcs total 3" ~ "Long acting reversible contraceptives",
    `Main method in use` == "Iu device" ~ "Long acting reversible contraceptives",
    `Main method in use` == "Iu system" ~ "Long acting reversible contraceptives",
    `Main method in use` == "Implant" ~ "Long acting reversible contraceptives",
    `Main method in use` == "Injectable contraceptive" ~ "Long acting reversible contraceptives",
    `Main method in use` == "User dependent methods total" ~  "User dependent",
    `Main method in use` == "Oral contraceptives" ~ "User dependent",
    `Main method in use` == "Male condom" ~ "User dependent",
    `Main method in use` == "Contraceptive patch" ~ "User dependent",
    `Main method in use` == "Natural family planning" ~ "User dependent",
    `Main method in use` == "Other methods 4" ~ "User dependent")) %>%
  rename(`Type of contraception` = `Main method in use`)


# Creates separate data frame for each age value and reformats slightly
Under16 <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "Under 16"))) %>% # selects these 3 columns
  mutate(`Age` = "15 and under") %>%
  rename(`Value` = `Under 16`)

`16 to 17` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "16-17"))) %>%
  mutate(`Age` = "16 to 17") %>%
  rename(`Value` = `16-17`)

`18 to 19` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "18-19"))) %>%
  mutate(`Age` = "18 to 19") %>%
  rename(`Value` = `18-19`)

`20 to 24` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "20-24"))) %>%
  mutate(`Age` = "20 to 24") %>%
  rename(`Value` = `20-24`)

`25 to 34` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "25-34"))) %>%
  mutate(`Age` = "25 to 34") %>%
  rename(`Value` = `25-34`)

`35 to 44`<-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "35-44"))) %>%
  mutate(`Age` = "35 to 44") %>%
  rename(`Value` = `35-44`)

`45 and over` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "45 and over"))) %>%
  mutate(`Age` = "45 and over") %>%
  rename(`Value` = `45 and over`)

`Total` <-  age_data_split %>%
  select(all_of(c("Main method of contraception",
                  "Type of contraception",
                  "Total"))) %>%
  mutate(`Age` = "Total") %>%
  rename(`Value` = `Total`)


# Combines each age data frame into one
age_data <- rbind(`Under16`, `16 to 17`, `18 to 19`, `20 to 24`, `25 to 34`, `35 to 44`, `45 and over`, `Total`)

# Fills these columns (left) with all of the same value (right)
age_data['Year']=year
age_data['Observation status'] = "Undefined"
age_data['Unit multiplier'] = "Thousands"
age_data['Unit measure']="Number"


# puts columnns in correct order
age_csv_ordered <-  age_data %>%
  select(all_of(c("Year", "Age", "Main method of contraception", "Type of contraception", "Observation status", "Unit multiplier", "Unit measure", "Value")))

# Replace these values with blanks
age_csv_ordered$`Type of contraception` <- gsub("Larcs total 3", "", as.character(age_csv_ordered$`Type of contraception`))
age_csv_ordered$`Type of contraception` <- gsub("Other methods 4", "", as.character(age_csv_ordered$`Type of contraception`))
# This one took a few goes because of the brackets
age_csv_ordered$`Type of contraception` <- gsub("Total with a method in use", "", as.character(age_csv_ordered$`Type of contraception`))
age_csv_ordered$`Type of contraception` <- gsub("thousands", "", as.character(age_csv_ordered$`Type of contraception`))
age_csv_ordered$`Type of contraception` <- gsub("[()]", "", as.character(age_csv_ordered$`Type of contraception`))
age_csv_ordered$`Age` <- gsub("Total", "", as.character(age_csv_ordered$`Age`))


# Order the rows by columns values, na values first
age_csv_sorted <- age_csv_ordered[order(age_csv_ordered$Year, age_csv_ordered$`Main method of contraception`,
                                        age_csv_ordered$`Type of contraception`, age_csv_ordered$Age,
                                        na.last = FALSE), ]


# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
age_csv_output <- age_csv_sorted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value)) %>%
  mutate(`Main method of contraception` = ifelse(is.na(`Main method of contraception`),
                                                 "", `Main method of contraception`))


# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
check_all_age <- nrow(distinct(age_csv_output)) == nrow(age_csv_output)





# LOCAL AUTHORITY
# Reads in local authority tab of spreadsheet and formats across columns
la_source_data <- read_excel(paste0(input_folder, "/", filename),
                              sheet = tabname_la, skip = header_row_la -1) %>% 
  mutate(across(where(is.factor), as.character)) %>%
  mutate(across(where(is.double), as.character))

# Trim source data into a smaller dataframe
la_source_data_sml <- la_source_data %>% 
  slice(2:162) %>% # selects rows 2 to 164
  slice(-2, -12) %>%  # removes these rows
  select(3:5, 7:11, 13:17) %>% # selects these columns
  rename("Total" = "...5", "LARC" = "Total...7", "IU device" = "IU device...8",
         "IU system" = "IU system...9", "Implant" = "Implant...10",
         "Injectable contraceptive" = "Injectable...11", "UD" = "Total...13", "Oral contraceptives" = "Oral (pill)...14",
         "Male condom" = "Male condom...15", "Contraceptive Patch" = "Patch...16", "Other" = "Other 2...17")  # renames these columns
  
# pivot the data into long format so that types of contraception are in one column
la_data_long <- la_source_data_sml %>%
  pivot_longer(Total:Other, names_to = "Type of contraception", values_to = "Value")

# creates a new dataframe with separate columns for main method of and type of contraception
la_data_split <- la_data_long %>%  
  mutate(`Main method of contraception` = case_when(
    `Type of contraception` == "LARC" ~ "Long acting reversible contraceptives",
    `Type of contraception` == "IU device" ~ "Long acting reversible contraceptives",
    `Type of contraception` == "IU system" ~ "Long acting reversible contraceptives",
    `Type of contraception` == "Implant" ~ "Long acting reversible contraceptives",
    `Type of contraception` == "Injectable contraceptive" ~ "Long acting reversible contraceptives",
    `Type of contraception` == "UD" ~  "User dependent",
    `Type of contraception` == "Oral contraceptives" ~ "User dependent",
    `Type of contraception` == "Male condom" ~ "User dependent",
    `Type of contraception` == "Contraceptive Patch" ~ "User dependent",
    `Type of contraception` == "Other" ~ "User dependent"))



# Fills these columns (left) with all of the same value (right)
la_data_split['Year']=year
la_data_split['Observation status'] = "Undefined"
la_data_split['Unit multiplier'] = "Thousands"
la_data_split['Unit measure']="Number"


# puts columnns in correct order
la_csv_ordered <-  la_data_split %>%
  select(all_of(c("Year", "Region name", "LA name", "Main method of contraception", "Type of contraception", "Observation status", "Unit multiplier", "Unit measure", "Value"))) 

# Replace these values with blanks
la_csv_ordered$`Region name` <- gsub("Total3", "", as.character(la_csv_ordered$`Region name`))
la_csv_ordered$`Type of contraception` <- gsub("Total", "", 
                                               as.character(la_csv_ordered$`Type of contraception`))
la_csv_ordered$`Type of contraception` <- gsub("LARC", "", 
                                               as.character(la_csv_ordered$`Type of contraception`))
la_csv_ordered$`Type of contraception` <- gsub("UD", "", 
                                               as.character(la_csv_ordered$`Type of contraception`))
la_csv_ordered$`Value` <- gsub("[*]", "",
                               as.character(la_csv_ordered$`Value`))

# DID NOT order for this set as it came sorted NE > SW
#la_csv_sorted <- la_csv_ordered[order(csv_ordered$Year, csv_ordered$`Main method of contraception`, csv_ordered$`Type of contraception`, csv_ordered$Age, na.last = FALSE), ]


# remove NAs from the csv that will be saved in Outputs
# this changes Value to a character so will still use csv_formatted in the 
# R markdown QA file
la_csv_output <- la_csv_ordered %>% 
  mutate(Value = ifelse(is.na(Value), "", Value)) %>%
  mutate(`Main method of contraception` = ifelse(is.na(`Main method of contraception`), "", `Main method of contraception`)) %>%
  mutate(`LA name` = ifelse(is.na(`LA name`), "", `LA name`))

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
check_all_la <- nrow(distinct(la_csv_output)) == nrow(la_csv_output)




# COMBINE AGE AND LA DATAFRAMES
# Add blank region and la columns to age df
age_csv_output['Region name'] = ""
age_csv_output['LA name'] = ""
# Add blank age column to la df
la_csv_output['Age'] = ""

# Join the 2 dfs and order the columns
csv_joined <- rbind(age_csv_output, la_csv_output) %>%
  select(all_of(c("Year", "Region name", "LA name", "Age", "Main method of contraception",
                  "Type of contraception", "Observation status", "Unit multiplier",
                  "Unit measure", "Value"))) # order the columns

# Remove duplicates (there will be some in the totals for the whole of England)
csv_output <- distinct(csv_joined)

# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows in the clean_population dataframe should be unique
# so this should be TRUE
check_all_joined <- nrow(distinct(csv_output)) == nrow(csv_output)