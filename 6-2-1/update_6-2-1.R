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
data_facility <- source_data_facility %>%
  mutate(Series = "Facility type") 

# The %>% is called a "pipe". Think of it as "and then do this"
  # the above line can therefore be read as:
  # "data facility is source data facility, and then
  # mutate a column called Series, populated with "Facility type""

# can you do for the other two data sets? 
  # Use https://sdgdata.gov.uk/6-2-1/ dropdowns to guide you
# data_safe <- 

# data_service <- 


data_safe <- source_data_safe %>% 
  mutate(Series = "Safely managed element")

data_service <- source_data_service %>%
  mutate(Series = "Service level")



#### Combine the three datasets ####
# will need to use the full join function, details for functions seen by using ?
?full_join 

data_part1 <- full_join(data_facility, data_safe)
combined_data <- full_join(data_part1, data_service)


#### Rename and select relevant columns ####
# some columns need renamed for the platform (e.g. Coverage to value)
   # use the rename function
?rename
# some columns are unnecessary to go onto the platform (e.g. ISO3)
   # use the select function to select columns we do need
    # this also orders the columns
?select

# clean_data <- source_data %>% 
  # rename() %>% 
  # select()


clean_data <- combined_data %>%
  rename(`Urban or rural` = `Residence Type`,
         Value = Coverage) %>% 
  select(Year, Series, `Safely managed element`, `Service level`,
         `Facility type`, `Urban or rural`, Value)


#### Tidy and reformat the dataframe ####

# Replace character NAs with blanks in Safely managed element, 
  # Service level, and Facility type columns 
clean_data  <- clean_data %>% 
  mutate_at(c("Safely managed element", "Service level", "Facility type"), ~replace_na(.,"")) 

# Ensure urban/rural column is in sentence case
clean_data  <- clean_data %>%  
  mutate(`Urban or rural` = toTitleCase(`Urban or rural`))
           
           
# In a similar way, can you ensure the value column is numeric
?as.numeric
csv_formatted  <- clean_data %>%  
  mutate(Value = as.numeric(Value)) 


# reformat the Urban or rural column so "total" is replaced by a blank
csv_formatted$`Urban or rural` <- gsub("Total", "", csv_formatted$`Urban or rural`)


# Add in the extra metadata columns
csv_formatted  <- csv_formatted %>%
  mutate(`Unit measure` = "Percentage (%)") %>%
  mutate(`Observation status` = case_when(Value != "NA" ~ "Normal value",
                                          TRUE ~ "Missing value")) %>%
  select(Year, Series, `Safely managed element`, `Service level`,
         `Facility type`, `Urban or rural`, `Unit measure`, 
         `Observation status`, Value) %>%
  arrange(Year, Series, `Safely managed element`, `Service level`,
          `Facility type`, `Urban or rural`)



# This is a line that you can run to check that you have filtered and selected 
# correctly - all rows should be unique, so this should be TRUE
check_all <- nrow(distinct(csv_formatted)) == nrow(csv_formatted)


# If false, this will remove duplicate rows. If true, run anyway.
csv_output <- unique(csv_formatted) 
