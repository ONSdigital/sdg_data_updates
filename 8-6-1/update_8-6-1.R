# author: Abhishek Singh
# date: 23/02/2023

# Code to automate data update for indicator 8-6-1 
# (Proportion of youth (aged 15–24 years) not in education, employment or training)

# Create a function "format_data_8_6_1" to filter, modify, and format data in
# required format, this function takes main_data, value of Seasonally Adjusted
# or Not in a variable as (NSA_or_SA), value of sex in a varialbe as (SEX)
# and return the final formatted data.

format_data_8_6_1 <- function(main_data,NSA_or_SA, SEX) { 
  data <- main_data
  
  data <- data %>%
    mutate(across(`X1`, str_replace, 'Jan-Mar', 'Q1'),
           across(`X1`, str_replace, 'Apr-Jun', 'Q2'), 
           across(`X1`, str_replace, 'Jul-Sep', 'Q3'), 
           across(`X1`, str_replace, 'Oct-Dec', 'Q4'))
  
  data <- data %>% separate(`X1`, c('quarter', 'year'))
  
  # format column name
  colnames(data) [3] <- "age_16-24_value"
  colnames(data) [4] <- "age_16-17_value"
  colnames(data) [5] <- "age_18-24_value"
  
  
  # filter the complete quarter year
  year_count <- data %>% count(year)
  year_count <- year_count[year_count$n == 4,] 
  
  
  # 1.format Quaterly_data for age_16-24 
  q_data_16_24 <- data
  q_data_16_24["Year"] <- paste(data$year, data$quarter)
  q_data_16_24 <- q_data_16_24  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training (quarterly)",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = q_data_16_24$`age_16-24_value`)
  
  
  #   1.1 format Yearly_data for age_16-24 
  data_by_year_16_24 <- filter(q_data_16_24, q_data_16_24$year %in% year_count$year)
  data_by_year_16_24 <- within(data_by_year_16_24, rm("quarter",
                                                      "age_16-17_value",
                                                      "age_18-24_value"))
  
  data_by_year_16_24['Value'] <- round(as.numeric(unlist(data_by_year_16_24['Value'])),2)
  
  data_by_year_agg_16_24 = aggregate(data_by_year_16_24,
                                     by = list(data_by_year_16_24$year),
                                     FUN = mean) 
  
  
  data_by_year_agg_16_24["Year"] <- data_by_year_agg_16_24["Group.1"]  
  data_by_year_agg_16_24 <- data_by_year_agg_16_24  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = data_by_year_agg_16_24$Value)
  
  data_by_year_agg_16_24 <- data_by_year_agg_16_24 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex",
           "Units", "Unit multiplier", "Observation status", "Value") 
  
  
  
  
  # remove unwanted column and filter required columns
  q_data_16_24 <- within(q_data_16_24, rm("quarter",
                                          "year",
                                          "age_16-24_value",
                                          "age_16-17_value",
                                          "age_18-24_value"))
  
  q_data_16_24 <- q_data_16_24 %>% select("Year",
                                          "Series", 
                                          "Seasonally adjusted or not", 
                                          "Age", 
                                          "Sex", 
                                          "Units", 
                                          "Unit multiplier",
                                          "Observation status",
                                          "Value")    
  
  
  # 2.format Quaterly_data for age_16-17 
  q_data_16_17 <- data
  q_data_16_17["Year"] <- paste(data$year, data$quarter)
  q_data_16_17 <- q_data_16_17  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training (quarterly)",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "16 to 17",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = q_data_16_17$`age_16-17_value`)
  
  #   2.1 format Yearly_data for age__16_17 
  data_by_year_16_17 <- filter(q_data_16_17, q_data_16_17$year %in% year_count$year)
  data_by_year_16_17 <- within(data_by_year_16_17, rm("quarter", 
                                                      "age_16-24_value",
                                                      "age_18-24_value"))
  
  data_by_year_16_17['Value'] <- round(as.numeric(unlist(data_by_year_16_17['Value'])),2)
  
  data_by_year_agg_16_17 = aggregate(data_by_year_16_17,
                                     by = list(data_by_year_16_17$year),
                                     FUN = mean) 
  
  data_by_year_agg_16_17["Year"] <- data_by_year_agg_16_17["Group.1"]
  data_by_year_agg_16_17 <- data_by_year_agg_16_17  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "16 to 17",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = data_by_year_agg_16_17$Value)
  
  data_by_year_agg_16_17 <- data_by_year_agg_16_17 %>% select("Year",
                                                              "Series",
                                                              "Seasonally adjusted or not",
                                                              "Age",
                                                              "Sex",
                                                              "Units",
                                                              "Unit multiplier",
                                                              "Observation status",
                                                              "Value")          
  
  # remove unwanted column and filter required columns
  q_data_16_17 <- within(q_data_16_17, rm("quarter",
                                          "year",
                                          "age_16-24_value",
                                          "age_16-17_value",
                                          "age_18-24_value"))
  
  q_data_16_17 <- q_data_16_17 %>%  select("Year",
                                           "Series",
                                           "Seasonally adjusted or not",
                                           "Age",
                                           "Sex",
                                           "Units",
                                           "Unit multiplier",
                                           "Observation status",
                                           "Value")   
  
  
  # 3.format Quaterly_data for age_18-24 
  q_data_18_24 <- data
  q_data_18_24["Year"] <- paste(data$year, data$quarter)
  q_data_18_24 <- q_data_18_24  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training (quarterly)",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "18 to 24",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = q_data_18_24$`age_18-24_value`)
  
  #   3.1 format Yearly_data for age__18_24 
  data_by_year_18_24 <- filter(q_data_18_24, q_data_18_24$year %in% year_count$year)
  data_by_year_18_24 <- within(data_by_year_18_24,rm("quarter",
                                                     "age_16-24_value",
                                                     "age_16-17_value"))
  
  data_by_year_18_24['Value'] <- round(as.numeric(unlist(data_by_year_18_24['Value'])),2)
  
  data_by_year_agg_18_24 = aggregate(data_by_year_18_24,
                                     by = list(data_by_year_18_24$year),
                                     FUN = mean) 
  
  data_by_year_agg_18_24["Year"] <- data_by_year_agg_18_24["Group.1"]
  data_by_year_agg_18_24 <- data_by_year_agg_18_24  %>%
    mutate("Series" = "Proportion of youth not in education, employment or training",
           "Seasonally adjusted or not" =  NSA_or_SA,
           "Age" =  "18 to 24",
           "Sex" =  SEX,
           "Units" =  "Percentage (%)",
           "Unit multiplier" =  "Units",
           "Observation status" = "Normal value",
           "Value" = data_by_year_agg_18_24$Value)
  
  data_by_year_agg_18_24 <- data_by_year_agg_18_24 %>% select("Year",
                                                              "Series",
                                                              "Seasonally adjusted or not",
                                                              "Age",
                                                              "Sex",
                                                              "Units",
                                                              "Unit multiplier",
                                                              "Observation status",
                                                              "Value") 
  
  
  # remove unwanted column and filter required columns
  q_data_18_24 <- within(q_data_18_24, rm("quarter",
                                          "year",
                                          "age_16-24_value",
                                          "age_16-17_value",
                                          "age_18-24_value"))
  
  q_data_18_24 <- q_data_18_24 %>%  select("Year",
                                           "Series",
                                           "Seasonally adjusted or not",
                                           "Age",
                                           "Sex",
                                           "Units",
                                           "Unit multiplier",
                                           "Observation status",
                                           "Value") 
  
  
  
  # Combine all data into single table with identical columns
  
  formatted_data <- rbind(data_by_year_agg_16_24,
                      q_data_16_24,
                      data_by_year_agg_16_17,
                      q_data_16_17,
                      data_by_year_agg_18_24,
                      q_data_18_24 )
  
  # return the table "formatted_data" as output for this function
  return(formatted_data)
}



# read in data and format it 

## People-SA
data_people_sa <- get_type1_data(header_row, filename, people_sa_tabname)
data_people_sa <- data_people_sa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_people_sa)
 # Extract & format data from Seasonally Adjusted NEET People table
data_people_sa <- format_data_8_6_1(data_people_sa,
                                     NSA_or_SA="Seasonally adjusted",
                                     SEX="")

## People-NSA
data_people_nsa <- get_type1_data(header_row, filename, people_nsa_tabname)
data_people_nsa <- data_people_nsa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_people_nsa)
# Extract & format data from Not seasonally adjusted NEET People table
data_people_nsa <- format_data_8_6_1(data_people_nsa,
                                     NSA_or_SA="Not seasonally adjusted",
                                     SEX="")

## Men-SA
data_men_sa <- get_type1_data(header_row, filename, men_sa_tabname)
data_men_sa <- data_men_sa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_men_sa)
# Extract & format data from Seasonally Adjusted NEET Man table
data_men_sa <- format_data_8_6_1(data_men_sa,
                                 NSA_or_SA="Seasonally adjusted",
                                 SEX="Male")

# Men-NSA
data_men_nsa <- get_type1_data(header_row, filename, men_nsa_tabname)
data_men_nsa <- data_men_nsa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_men_nsa)
# Extract & format data from Not seasonally adjusted Man People table
data_men_nsa <- format_data_8_6_1(data_men_nsa, 
                                  NSA_or_SA="Not seasonally adjusted",
                                  SEX="Male")


# Women-SA
data_women_sa <- get_type1_data(header_row, filename, women_sa_tabname)
data_women_sa <- data_women_sa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_women_sa)
# Extract & format data from Seasonally Adjusted NEET Woman table
data_women_sa <- format_data_8_6_1(data_women_sa, 
                                   NSA_or_SA="Seasonally adjusted", 
                                   SEX="Female")

# Women-NSA
data_women_nsa <- get_type1_data(header_row, filename, women_nsa_tabname)
data_women_nsa <- data_women_nsa[c(1,6,11,16)] %>%
  filter(X6 != "..") %>%
  na.omit(data_women_nsa)
# Extract & format data from Not seasonally adjusted NEET Woman table
data_women_nsa <- format_data_8_6_1(data_women_nsa,
                                    NSA_or_SA="Not seasonally adjusted",
                                    SEX="Female")


# combine all data together into final dataframe
csv_output <- rbind(data_people_sa,
                    data_people_nsa,
                    data_men_sa,
                    data_men_nsa,
                    data_women_sa,
                    data_women_nsa)










