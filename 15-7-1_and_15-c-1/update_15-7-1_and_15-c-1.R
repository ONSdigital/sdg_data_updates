# author: Katie Uzzell
# date: 14/07/2022

# Code to automate data update for indicator 15-7-1 and 15-c-1 (number of endangered species seizures)

# read in data 

seizures_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

seizures_main_data <- extract_data(seizures_source_data, header_row)

# remove superscripts from column names

names(seizures_main_data) <- SDGupdater::remove_superscripts(names(seizures_main_data)) 

# rename columns

renamed_seizures_main_data <- seizures_main_data %>% 
  rename_column(primary = "Total Number of Seizures", new_name = "Total Number of Seizures") %>% 
  rename_column(primary = "Number of Times seized: Caviar & Caviar extract", new_name = "Caviar and Caviar extract") %>% 
  rename_column(primary = "Number of Times seized: Live Coral & Coral Derivatives", new_name = "Live Coral and Coral Derivatives") %>% 
  rename_column(primary = "Number of Times seized: Ivory and Items Containing Ivory", new_name = "Ivory and Items Containing Ivory") %>% 
  rename_column(primary = "Number of Times seized: Live Animals and Birds", new_name = "Live Animals and Birds") %>%
  rename_column(primary = "Number of Times seized: Live Plants", new_name = "Live Plants") %>%
  rename_column(primary = "Number of Times seized: Parts or Derivatives of Animals/Birds", new_name = "Parts or Derivatives of Animals or Birds") %>%
  rename_column(primary = "Number of Times seized: Parts or Derivatives of Plants", new_name = "Parts or Derivatives of Plants") %>%
  rename_column(primary = "Number of Times seized: Timber or Wood Products", new_name = "Timber or Wood Products") %>%
  rename_column(primary = "Number of Times seized: Preparations Of Oriental Medicine Which Include Parts & Derivatives Of Endangered Species", new_name = "Preparations Of Oriental Medicine Which Include Parts and Derivatives Of Endangered Species") %>%
  rename_column(primary = "Number of Times seized: Butterflies", new_name = "Butterflies") 

# split year and quarter column into two

renamed_seizures_main_data[c('Year', 'Quarter')] <- str_split_fixed(renamed_seizures_main_data$Quarter, ' ', 2)

# select wanted columns

renamed_seizures_main_data <- renamed_seizures_main_data %>% 
  select(c("Year", "Quarter", "Total Number of Seizures", "Caviar and Caviar extract", "Live Coral and Coral Derivatives", "Ivory and Items Containing Ivory", "Live Animals and Birds", "Live Plants", "Parts or Derivatives of Animals or Birds", "Parts or Derivatives of Plants", "Timber or Wood Products", "Preparations Of Oriental Medicine Which Include Parts and Derivatives Of Endangered Species", "Butterflies"))

# remove rows containing only NAs

renamed_seizures_main_data <- na.omit(renamed_seizures_main_data)

# change ":" to NAs

renamed_seizures_main_data[renamed_seizures_main_data == ":"] <- "NA" 

# calculate total seizures for each import type for each year

seizures_main_data_totals <- subset(renamed_seizures_main_data, select = -Quarter)

# change column names to sentence case

seizures_main_data_totals <- seizures_main_data_totals %>%
  rename_with(str_to_sentence)

# format into csv and remove NAs

seizures_main_data_totals <- seizures_main_data_totals %>%
  pivot_longer(-c("Year"), names_to = "Import type", values_to = "Value")

select_NAs <- seizures_main_data_totals %>% filter(Value == "NA")

seizures_main_data_totals <- seizures_main_data_totals %>%
  filter(Value != "NA")

# Aggregate values for each import type by year

seizures_main_data_totals$`Value` <- as.numeric(seizures_main_data_totals$`Value`)

seizures_main_data_totals <- seizures_main_data_totals %>%
  group_by(Year, `Import type`) %>%
  summarise_at(vars(Value),
  list(Value = sum))

# Format csv 

csv_formatted <- seizures_main_data_totals %>% 
         mutate("Unit measure" = "Number of times seized",
                "Unit multiplier" =  "Units",
                "Observation status" = "Normal value")

csv_formatted <- csv_formatted %>%            
select("Year", "Import type", "Unit measure", "Unit multiplier", "Observation status", "Value")

csv_formatted <- csv_formatted[order(csv_formatted$"Import type"),]

csv_output <- csv_formatted %>% 
  mutate(Value = ifelse(is.na(Value), "", Value))
