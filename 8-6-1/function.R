library('openxlsx')
library("readxl")
library('stringr')
library('janitor')
library('tidyr')
library('dplyr')

setwd("D:/new/sdg_data_updates/8-6-1/Example_Input")
source_data = read_excel("8.6.1.xlsx",sheet = "Source 1",col_names=FALSE)

main_data= source_data[c(1,6,11,16)]


# create a function

format_data_8_6_1 <- function(tStart,tEnd,main_data,NSA_or_SA, SEX) { # create a function with the name my_function
  data <- main_data[tStart:tEnd,]
  
  # person_SA["Old_col"] <- person_SA[c(1)]
  
  
  data <- data %>%
    mutate(across(`...1`, str_replace, 'Jan-Mar', 'Q1'),across(`...1`, str_replace, 'Apr-Jun', 'Q2')
           ,across(`...1`, str_replace, 'Jul-Sep', 'Q3'),across(`...1`, str_replace, 'Oct-Dec', 'Q4'))
  
  data <- data %>% separate(`...1`, c('quarter', 'year'))
  
  # format column name
  colnames(data) [3] <- "age_16-24_value"
  colnames(data) [4] <- "age_16-17_value"
  colnames(data) [5] <- "age_18-24_value"
  
  
  
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
  data_by_year_16_24 <- 
    within(data_by_year_16_24, rm("quarter","age_16-17_value", "age_18-24_value"))
  
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
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value") 
  
  #   print(data_by_year_agg)
  
  
  # remove unwanted column
  q_data_16_24 <- 
    within(q_data_16_24, rm("quarter","year","age_16-24_value","age_16-17_value", "age_18-24_value"))
  
  # select columns
  q_data_16_24 <- q_data_16_24 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value")    
  
  
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
  data_by_year_16_17 <- 
    within(data_by_year_16_17, rm("quarter","age_16-24_value", "age_18-24_value"))
  
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
  
  data_by_year_agg_16_17 <- data_by_year_agg_16_17 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value")          
  
  # remove unwanted column
  q_data_16_17 <- 
    within(q_data_16_17, rm("quarter","year","age_16-24_value","age_16-17_value", "age_18-24_value"))
  # select columns
  q_data_16_17 <- q_data_16_17 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value")   
  
  
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
  data_by_year_18_24 <- 
    within(data_by_year_18_24, rm("quarter","age_16-24_value", "age_16-17_value"))
  
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
  
  data_by_year_agg_18_24 <- data_by_year_agg_18_24 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value") 
  
  
  # remove unwanted column
  q_data_18_24 <- 
    within(q_data_18_24, rm("quarter","year","age_16-24_value","age_16-17_value", "age_18-24_value"))
  
  q_data_18_24 <- q_data_18_24 %>%
    select("Year", "Series","Seasonally adjusted or not","Age","Sex", "Units", "Unit multiplier", "Observation status", "Value") 
  
  #   print(q_data_18_24)
  
  data_by_year_agg_16_24
  q_data_16_24
  data_by_year_agg_16_17
  q_data_16_17
  data_by_year_agg_18_24  
  q_data_18_24
  csv_output <- rbind(data_by_year_agg_16_24, q_data_16_24, data_by_year_agg_16_17, q_data_16_17, data_by_year_agg_18_24, q_data_18_24 )
  
  return(csv_output)
}


# new function
# yearly_data <- function(data) { # create a function to count full Quarter


#        year_count <- data %>% count(year)
#        year_count <- year_count[year_count$n == 4,] 


#        data_byyear <- filter(data, data$year %in% year_count$year)
#        print(year_count)
#        print(data_byyear)
#        return(year_count)

# }




# Extract & format data from Seasonally Adjusted NEET People table
data_people_sa <- format_data_8_6_1(21,102,main_data,NSA_or_SA="Seasonally adjusted",SEX="")

# Extract & format data from Not seasonally adjusted NEET People table
data_people_nsa <- format_data_8_6_1(294,375,main_data, NSA_or_SA="Not seasonally adjusted", SEX="")

# Extract & format data from Seasonally Adjusted NEET Man table
data_men_sa <- format_data_8_6_1(111,192,main_data, NSA_or_SA="Seasonally adjusted",SEX="Male")

# Extract & format data from Not seasonally adjusted Man People table
data_men_nsa <- format_data_8_6_1(385,466,main_data, NSA_or_SA="Not seasonally adjusted", SEX="Male")

# Extract & format data from Seasonally Adjusted NEET Man table
data_women_sa <- format_data_8_6_1(203,284,main_data, NSA_or_SA="Seasonally adjusted",SEX="Female")

# Extract & format data from Not seasonally adjusted Man People table
data_women_nsa <- format_data_8_6_1(476,557,main_data, NSA_or_SA="Not seasonally adjusted", SEX="Female")





