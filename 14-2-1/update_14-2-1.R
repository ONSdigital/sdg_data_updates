# author: Abhishek Singh
# date: 01/02/2023

# Code to automate data update for indicator 14-2-1 (Total extent and proportion of protected areas at sea)


library(dplyr)

# read in data 

protected_area_source_data <- get_type1_data(header_row, filename, tabname)

# remove cells above column names

protected_area_main_data <- extract_data(protected_area_source_data, header_row)


# rename columns 1 and 3

colnames(protected_area_main_data) [1] <- "Year"

colnames(protected_area_main_data) [3] <- "At_Sea"



# convert to numeric and round
protected_area_main_data['At_Sea'] <- round(as.numeric(unlist(protected_area_main_data['At_Sea'])),9)


# remove unwanted columns

protected_area_main_data <- within(protected_area_main_data, rm("Total extent\n (million hectares)", "Extent on land \n(million hectares)"))

# select only needed rows

selected_rows <- c(1:77)


# filter selected rows
protected_area_main_data <- protected_area_main_data %>%
  slice(selected_rows)

# Remove NA values
protected_area_main_data <- protected_area_main_data %>%
  na.omit()


# Add this constant column with value 88.613
protected_area_main_data['UK_marine_area'] <- 88.613

# format

# rename column 2

colnames(protected_area_main_data) [2] <- "At_Sea"

# Calculations were made to generate the “Proportion of marine protected area” series. Proportion of marine protected area is calculated using the following formula. 100 * (Extent at sea - million hectares / UK sea area). 

# calculate and round the value

protected_area_main_data['Proportion_of_area_protected']  <- round((protected_area_main_data['At_Sea']/protected_area_main_data['UK_marine_area'])*100, 2)


# print(protected_area_main_data) just to check data is in appropriate format
protected_area_main_data['At_Sea'] <- round(as.numeric(unlist(protected_area_main_data['At_Sea'])), 2)

# prepare the first data frame having data for Series(Proportion of marine protected area)
df1 <- protected_area_main_data  %>%
         mutate("Series" = "Proportion of marine protected area",
           "Units" = "Percentage (%)",
            "Unit multiplier" =  "Unit",
            "Observation status" = "Normal value")
# format column name
colnames(df1) [4] <- "Value"

# remove unwanted column
df1 <- within(df1, rm("UK_marine_area"))

# save data frame having proper column sequence "Year", "Series", "Observation status",  "Unit multiplier", "Units", "Value"
df1 = df1 %>%
  select("Year", "Series", "Observation status",  "Unit multiplier", "Units", "Value")




# prepare the first data frame having data for Series(Marine protected area extent)
df2 <- protected_area_main_data  %>%
  mutate("Series" = "Marine protected area extent",
         "Units" = "Million hectares",
         "Unit multiplier" =  "Unit",
         "Observation status" = "Normal value")

# format column name
colnames(df2) [2] <- "Value"

# remove unwanted column
df2 <- within(df2, rm("UK_marine_area"))

# save data frame having proper column sequence "Year", "Series", "Observation status",  "Unit multiplier", "Units", "Value"
df2 = df2 %>%
    select("Year", "Series", "Observation status",  "Unit multiplier", "Units", "Value")

# join dataframe df1 and df2 vertically(df1 followed by df2) and save them in csv_output

csv_output <- rbind(df1, df2)


