# author: Abhishek Singh
# date: 23/02/2023

# Code to automate data update for indicator 8-6-1 
# (Proportion of youth (aged 15–24 years) not in education, employment or training)


# read in data 

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










