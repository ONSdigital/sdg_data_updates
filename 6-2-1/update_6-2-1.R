# author: Michael Nairn and Tom McNulty
# date: 04/07/2023

# Code to automate data update for indicator 6-2-1 
# Proportion of population using (a) safely managed sanitation services and 
  # (b) a hand-washing facility with soap and water


#### Read in data ####

source_data_facility <- readr::read_csv(file = paste0(input_folder, "/", filename_facility))
source_data_safe <- readr::read_csv(file = paste0(input_folder, "/", filename_safe))
source_data_service <- readr::read_csv(file = paste0(input_folder, "/", filename_service))                                   


#### Add a new column into each dataframe called Series ####
data_facility <- source_data_facility

data_safe <- source_data_safe

data_service <- source_data_service 


#### Combine the three datasets ####
# will need to use the full join function, details for functions seen by using 
?full_join 

# I have combined two of the three datasets. 
  # Can you join the new dataset I have made with the third one (data_service)?

data_part1 <- full_join(data_facility, data_safe)
source_data<- full_join(data_part1, data_service)


#### Rename and select relevant columns ####
# some columns need renamed for the platform (e.g. Coverage to value)
   # use the rename function
?rename
source_data <- rename(source_data, "Value" = "Coverage")

source_data <- rename(source_data, "Urban or rural" = "Residence Type")

# some columns are unnecessary to go onto the platform (e.g. ISO3)
   # use the select function to select columns we do need
    # this also orders the columns
?select
clean_data <- source_data %>%
  mutate(Series = "Proportion of population using safely managed sanitation services (%)") %>%
  select("Year", "Series", "Safely managed element", "Service level", "Facility type", "Urban or rural", "Value")
# clean_data <- source_data %>% 
  # rename() %>% 
  # select()


#### Tidy and reformat the dataframe ####
# This is vital for publication on platform

# Replace character NAs with blanks in Safely managed element, 
  # Service level, and Facility type columns 
clean_data  <- clean_data %>%
  mutate_at(c("Safely managed element", "Service level", "Facility type"), ~replace_na(.,"")) 

# this is a little more complex, so I have done for you. Run below line for details
?mutate_at

# Ensure urban/rural column is in title case
clean_data  <- clean_data %>%  
  mutate(`Urban or rural` = toTitleCase(`Urban or rural`))
           
           
# In a similar way, can you ensure the value column is numeric
?as.numeric
csv_formatted <- clean_data%>% 
  mutate(as.numeric(Value))


# reformat the Urban or rural column so "total" is replaced by a blank
   # use gsub function
 csv_formatted$"Urban or rural" <- gsub("Total","",csv_formatted$"Urban or rural")

?gsub




# Add in the extra metadata columns for platform
  # I have done this 
csv_formatted  <- csv_formatted %>%
  mutate(`Units` = "Percentage (%)") %>%
  mutate(`Unit multiplier` = "Units") %>%
  mutate(`Observation status` = case_when(Value != "NA" ~ "Normal value",
                                          TRUE ~ "Missing value")) %>%
  select(Year, Series, `Safely managed element`, `Service level`,
         `Facility type`, `Urban or rural`, `Units`, `Unit multiplier`,
         `Observation status`, Value) %>%
  arrange(Year, Series, `Safely managed element`, `Service level`,
          `Facility type`, `Urban or rural`)



# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)


# If false, this will remove duplicate rows. If true, run anyway.
csv_output <- unique(csv_formatted) 
