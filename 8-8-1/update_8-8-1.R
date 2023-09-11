# author: Katie Uzzell
# date: 17/08/2023

# Code to automate data update for indicator 8-8-1 (Rates of fatal and non-fatal 
# occupational injuries (excluding injuries arising from road traffic accidents)).

# read in data 

fatal_inj_headline_source <- get_type1_data(fatal_inj_header_row, fatal_inj_headline, fatal_tabname)
fatal_inj_region_source <- get_type1_data(fatal_inj_header_row, fatal_inj_region, fatal_tabname)
fatal_inj_age_sex_source <- get_type1_data(fatal_inj_header_row, fatal_inj_age_sex, fatal_tabname)
nonfatal_inj_summary_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_summary, nonfatal_tabname)
nonfatal_inj_region_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_region, nonfatal_tabname)
nonfatal_inj_age_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_age, nonfatal_tabname)
nonfatal_inj_ind_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_ind, nonfatal_tabname)
nonfatal_inj_occ_source <- get_type1_data(nonfatal_header_row, nonfatal_inj_occ, nonfatal_tabname)


# remove cells above column names

fatal_inj_headline_main <- extract_data(fatal_inj_headline_source, fatal_inj_header_row)
fatal_inj_region_main <- extract_data(fatal_inj_region_source, fatal_inj_header_row)
fatal_inj_age_sex_main <- extract_data(fatal_inj_age_sex_source, fatal_inj_header_row)
nonfatal_inj_summary_main <- extract_data(nonfatal_inj_summary_source, nonfatal_header_row)
nonfatal_inj_region_main <- extract_data(nonfatal_inj_region_source, nonfatal_header_row)
nonfatal_inj_age_main <- extract_data(nonfatal_inj_age_source, nonfatal_header_row)
nonfatal_inj_ind_main <- extract_data(nonfatal_inj_ind_source, nonfatal_header_row)
nonfatal_inj_occ_main <- extract_data(nonfatal_inj_occ_source, nonfatal_header_row)


# fatal injuries headline

fatal_inj_headline_main <- fatal_inj_headline_main[ , grepl('Year|Industry|Rate of fatal injury per 100,000 workers', names(fatal_inj_headline_main))]

fatal_inj_headline_main <- fatal_inj_headline_main %>% 
  select(-contains("Industry classification"))

colnames(fatal_inj_headline_main) [1] <- "Year"
colnames(fatal_inj_headline_main) [2] <- "Industry sector"
colnames(fatal_inj_headline_main) [3] <- "Value"

fatal_inj_headline_main <- fatal_inj_headline_main %>% 
  filter(!Year %in% c("1974",
                      "1975",
                      "1976",
                      "1977",
                      "1978",
                      "1979",
                      "1980",
                      "1981",
                      "1982",
                      "1983",
                      "1984",
                      "1985",
                      "1986/87 ",
                      "1987/88",
                      "1988/89",
                      "1989/90",
                      "1990/91",
                      "1991/92",
                      "1992/93",
                      "1993/94",
                      "1994/95",
                      "1995/96",
                      "1996/97 ",
                      "1997/98",
                      "1998/99",
                      "1999/00",
                      "2000/01",
                      "2001/02"))

fatal_inj_headline_main$`Industry sector`[fatal_inj_headline_main$`Industry sector` == "All industries"] <- ""

# Need to find a future proof way to replace Notes and r/p 

fatal_inj_headline_main$`Industry sector`[fatal_inj_headline_main$`Industry sector` == "Agriculture, forestry and fishing [Note 8]"] <- "Agriculture, forestry and fishing"

fatal_inj_headline_main$`Year`[fatal_inj_headline_main$`Year` == "2019/20 [Note 16]"] <- "2019/20"

fatal_inj_headline_main$`Year`[fatal_inj_headline_main$`Year` == "2020/21r [Note 16] [Note 17]"] <- "2020/21"

fatal_inj_headline_main$`Year`[fatal_inj_headline_main$`Year` == "2021/22p [Note 16] [Note 17]"] <- "2021/22"

fatal_inj_headline_main$`Industry sector` <- trimws(fatal_inj_headline_main$`Industry sector`, whitespace = "[ \t\r\n]")

# fatal injuries region

fatal_inj_region_main <- fatal_inj_region_main[ , grepl('Year|Area|Rate of fatal injury per 100,000 workers', names(fatal_inj_region_main))]

fatal_inj_region_main <- fatal_inj_region_main %>% 
  select(-contains("Area code"))

colnames(fatal_inj_region_main) [1] <- "Year"
colnames(fatal_inj_region_main) [2] <- "Region"
colnames(fatal_inj_region_main) [3] <- "Value"

fatal_inj_region_main$Region <- trimws(fatal_inj_region_main$Region, whitespace = "[ \t\r\n]")

fatal_inj_region_main <- fatal_inj_region_main %>% 
  filter(Region %in% c("ENGLAND AND WALES",
                      "ENGLAND",
                      "WALES",
                      "SCOTLAND",
                      "NORTH EAST",
                      "NORTH WEST",
                      "YORKSHIRE AND THE HUMBER",
                      "EAST MIDLANDS",
                      "WEST MIDLANDS",
                      "EAST",
                      "LONDON",
                      "SOUTH EAST",
                      "SOUTH WEST"))

fatal_inj_region_main <- fatal_inj_region_main %>%
  mutate(Country = case_when(
    Region == "ENGLAND AND WALES" ~ "England and Wales",
    Region == "WALES" ~ "Wales",
    Region == "SCOTLAND" ~ "Scotland",
    Region == "ENGLAND" ~ "England",
    Region == "NORTH EAST" ~ "England",
    Region == "NORTH WEST" ~ "England",
    Region == "YORKSHIRE AND THE HUMBER" ~ "England",
    Region == "EAST MIDLANDS" ~ "England",
    Region == "WEST MIDLANDS" ~ "England",
    Region == "EAST" ~ "England",
    Region == "LONDON" ~ "England",
    Region == "SOUTH EAST" ~ "England",
    Region == "SOUTH WEST" ~ "England"))


fatal_inj_region_main <- fatal_inj_region_main %>%
  mutate(Region = case_when(
    Region == "ENGLAND AND WALES" ~ "",
    Region == "WALES" ~ "",
    Region == "SCOTLAND" ~ "",
    Region == "ENGLAND" ~ "",
    Region == "NORTH EAST" ~ "North East",
    Region == "NORTH WEST" ~ "North West",
    Region == "YORKSHIRE AND THE HUMBER" ~ "Yorkshire and The Humber",
    Region == "EAST MIDLANDS" ~ "East Midlands",
    Region == "WEST MIDLANDS" ~ "West Midlands",
    Region == "EAST" ~ "East",
    Region == "LONDON" ~ "London",
    Region == "SOUTH EAST" ~ "South East",
    Region == "SOUTH WEST" ~ "South West"))

fatal_inj_region_main <- fatal_inj_region_main %>%
  select("Year", "Country", "Region", "Value")

# Need to find a future proof way to replace Notes and r/p

fatal_inj_region_main$`Year`[fatal_inj_region_main$`Year` == "2019/20 [Note 7]"] <- "2019/20"

fatal_inj_region_main$`Year`[fatal_inj_region_main$`Year` == "2020/21r [Note 7] [Note 8]"] <- "2020/21"

fatal_inj_region_main$`Year`[fatal_inj_region_main$`Year` == "2021/22p [Note 7] [Note 8]"] <- "2021/22"

# fatal injuries age and sex

fatal_inj_age_sex_main <- fatal_inj_age_sex_main[ , grepl('Year|Main Industry|Gender|Age|Rate of fatal injury per 100,000 workers', names(fatal_inj_age_sex_main))]

colnames(fatal_inj_age_sex_main) [1] <- "Year"
colnames(fatal_inj_age_sex_main) [2] <- "Industry sector"
colnames(fatal_inj_age_sex_main) [3] <- "Sex"
colnames(fatal_inj_age_sex_main) [4] <- "Age"
colnames(fatal_inj_age_sex_main) [5] <- "Value"

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>% 
  filter(!Age %in% c("Unknown"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main[fatal_inj_age_sex_main$`Industry sector` == "All industry", ]

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate(Age = case_when(
    Age == "All" ~ "",
    Age == "Under 16" ~ "Under 16",
    Age == "16-19" ~ "16 to 19",
    Age == "20-24" ~ "20 to 24",
    Age == "25-34" ~ "25 to 34",
    Age == "35-44" ~ "35 to 44",
    Age == "45-54" ~ "45 to 54",
    Age == "55-59" ~ "55 to 59",
    Age == "60-64" ~ "60 to 64",
    Age == "65+" ~ "65 and over"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>% 
  filter(!Sex %in% c("Unknown"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate(Sex = case_when(
    Sex == "All" ~ "",
    Sex == "Male" ~ "Male",
    Sex == "Female" ~ "Female"))

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>%
  mutate("Industry sector" = "")

fatal_inj_age_sex_main <- fatal_inj_age_sex_main[fatal_inj_age_sex_main$`Industry sector`!="" | fatal_inj_age_sex_main$`Sex`!="" | fatal_inj_age_sex_main$`Age`!="", ]

# Need to find a future proof way to replace Notes and r/p

fatal_inj_age_sex_main$`Year`[fatal_inj_age_sex_main$`Year` == "2019/20 [Note 9]"] <- "2019/20"

fatal_inj_age_sex_main$`Year`[fatal_inj_age_sex_main$`Year` == "2020/21r [Note 9] [Note 10]"] <- "2020/21"

fatal_inj_age_sex_main$`Year`[fatal_inj_age_sex_main$`Year` == "2021/22p [Note 9] [Note 10]"] <- "2021/22"

# Then join fatal data

fatal_inj_headline_main <- fatal_inj_headline_main %>% 
  mutate(Country = "",
         Region = "")

fatal_inj_region_main <- fatal_inj_region_main %>% 
  mutate(`Industry sector` = "")


fatal_joined_data <- rbind(fatal_inj_headline_main, 
                               fatal_inj_region_main)

fatal_inj_age_sex_main <- fatal_inj_age_sex_main %>% 
  mutate(Country = "",
         Region = "")      

fatal_joined_data <- fatal_joined_data %>% 
  mutate(Age = "",
         Sex = "")

fatal_joined_data <- rbind(fatal_joined_data, 
                               fatal_inj_age_sex_main)

fatal_joined_data <- fatal_joined_data %>% 
  replace(is.na(.), "")

fatal_joined_data <- fatal_joined_data %>% 
  mutate("Series" = "Fatal injury",
         "Units" = "Rate per 100,000 workers",
         "Unit multiplier" =  "Units",
         "Observation status" = "Normal value",
         "Occupation" = "")

fatal_joined_data <- fatal_joined_data %>% 
  select("Year", 
         "Series", 
         "Age", 
         "Sex", 
         "Country", 
         "Region", 
         "Industry sector",
         "Occupation", 
         "Units", 
         "Unit multiplier", 
         "Observation status", 
         "Value")

fatal_joined_data$`Value`[fatal_joined_data$`Value` == "-"] <- ""

fatal_joined_data <- fatal_joined_data %>% 
  mutate("Observation status" = case_when(fatal_joined_data$Value == "" ~ "Missing value",
                                          fatal_joined_data$Value != "" ~ "Normal value"))

# Non-fatal data

# non-fatal summary

nonfatal_inj_summary_main <- nonfatal_inj_summary_main %>% 
  select("Year", "Rate per 100,000 workers")

nonfatal_inj_summary_main <- nonfatal_inj_summary_main[-c(1, 2, 3, 4), ]

colnames(nonfatal_inj_summary_main) [2] <- "Value"

# Need to find a future proof way to replace Notes 

nonfatal_inj_summary_main$`Year`[nonfatal_inj_summary_main$`Year` == "2019/20 (Note A, Note B)"] <- "2019/20"

nonfatal_inj_summary_main$`Year`[nonfatal_inj_summary_main$`Year` == "2020/21 (Note A, Note B)"] <- "2020/21"

nonfatal_inj_summary_main$`Year`[nonfatal_inj_summary_main$`Year` == "2021/22 (Note A, Note B)"] <- "2021/22"

nonfatal_inj_summary_main <- nonfatal_inj_summary_main %>% 
  mutate("Units" = "Rate per 100,000 workers",
         "Observation status" = "Normal Value")

# non-fatal region

nonfatal_inj_region_main <- nonfatal_inj_region_main %>% 
  select("Year", 
         "Usual country and region of residence", 
         "Averaged rate per 100,000 workers")

nonfatal_inj_region_main <- nonfatal_inj_region_main[-c(1, 2, 3, 4), ]

colnames(nonfatal_inj_region_main) [2] <- "Region"
colnames(nonfatal_inj_region_main) [3] <- "Value"

nonfatal_inj_region_main <- nonfatal_inj_region_main %>% 
  filter(Region %in% c("England",
                       "Wales",
                       "Scotland",
                       "North East",
                       "North West",
                       "Yorkshire and The Humber",
                       "East Midlands",
                       "West Midlands",
                       "East",
                       "London",
                       "South East",
                       "South West"))

nonfatal_inj_region_main <- nonfatal_inj_region_main %>%
  mutate(Country = case_when(
    Region == "Wales" ~ "Wales",
    Region == "Scotland" ~ "Scotland",
    Region == "England" ~ "England",
    Region == "North East" ~ "England",
    Region == "North West" ~ "England",
    Region == "Yorkshire and The Humber" ~ "England",
    Region == "East Midlands" ~ "England",
    Region == "West Midlands" ~ "England",
    Region == "East" ~ "England",
    Region == "London" ~ "England",
    Region == "South East" ~ "England",
    Region == "South West" ~ "England"))

nonfatal_inj_region_main <- nonfatal_inj_region_main %>%
  mutate(Region = case_when(
    Region == "Wales" ~ "",
    Region == "Scotland" ~ "",
    Region == "England" ~ "",
    Region == "North East" ~ "North East",
    Region == "North West" ~ "North West",
    Region == "Yorkshire and The Humber" ~ "Yorkshire and The Humber",
    Region == "East Midlands" ~ "East Midlands",
    Region == "West Midlands" ~ "West Midlands",
    Region == "East" ~ "East",
    Region == "London" ~ "London",
    Region == "South East" ~ "South East",
    Region == "South West" ~ "South West"))

nonfatal_inj_region_main <- nonfatal_inj_region_main %>%
  select("Year", "Country", "Region", "Value")

# Need to find a future proof way to replace Notes 

nonfatal_inj_region_main$`Year`[nonfatal_inj_region_main$`Year` == "2019/20-2021/22 (Note A, Note B)"] <- "2019/20-2021/22"

nonfatal_inj_region_main <- nonfatal_inj_region_main %>% 
  mutate("Units" = "Rate per 100,000 (3 year average)",
         "Observation status" = "Estimated Value")

nonfatal_inj_region_main <- nonfatal_inj_region_main %>%
  mutate(Year = case_when(
    Year == "2001/02-2003/04" ~ "2002/03",
    Year == "2002/03-2004/05" ~ "2003/04",
    Year == "2003/04-2005/06" ~ "2004/05",
    Year == "2004/05-2006/07" ~ "2005/06",
    Year == "2005/06-2007/08" ~ "2006/07",
    Year == "2006/07-2008/09" ~ "2007/08",
    Year == "2007/08-2009/10" ~ "2008/09",
    Year == "2008/09-2010/11" ~ "2009/10",
    Year == "2009/10-2011/12" ~ "2010/11",
    Year == "2010/11-2012/13" ~ "2011/12",
    Year == "2011/12-2013/14" ~ "2012/13",
    Year == "2012/13-2014/15" ~ "2013/14",
    Year == "2013/14-2015/16" ~ "2014/15",
    Year == "2014/15-2016/17" ~ "2015/16",
    Year == "2015/16-2017/18" ~ "2016/17",
    Year == "2016/17-2018/19" ~ "2017/18",
    Year == "2017/18-2019/20" ~ "2018/19",
    Year == "2018/19-2020/21" ~ "2019/20",
    Year == "2019/20-2021/22" ~ "2020/21",
    Year == "2019/20-2021/22" ~ "2020/21"))

# non-fatal age

nonfatal_inj_age_main <- nonfatal_inj_age_main %>% 
  select("Year", "Age group and gender", "Averaged rate per 100,000 workers")

nonfatal_inj_age_main <- nonfatal_inj_age_main[-c(1, 2, 3, 4), ]

nonfatal_inj_age_main <- nonfatal_inj_age_main %>%
  mutate(Sex = case_when(
    `Age group and gender` %in% c("Male", "Male - 16-24", "Male - 25-34", "Male - 35-44", "Male - 45-54", "Male - 55+") ~ "Male", 
    `Age group and gender` %in% c("Female", "Female - 16-24", "Female - 25-34", "Female - 35-44", "Female - 45-54", "Female - 55+") ~ "Female", 
    TRUE ~ ""))

nonfatal_inj_age_main <- nonfatal_inj_age_main %>%
  rename("Age" = "Age group and gender")

nonfatal_inj_age_main <- nonfatal_inj_age_main %>%
  rename("Value" = "Averaged rate per 100,000 workers")

nonfatal_inj_age_main <- nonfatal_inj_age_main %>%
  mutate(Age = case_when(
    Age == "All persons" ~ "",
    Age == "Male" ~ "",
    Age == "Female" ~ "",
    Age == "16-24" ~ "16 to 24", 
    Age == "25-34" ~ "25 to 34", 
    Age == "35-44" ~ "35 to 44", 
    Age == "45-54" ~ "45 to 54", 
    Age == "55+" ~ "55 and over",
    Age == "Male - 16-24" ~ "16 to 24", 
    Age == "Male - 25-34" ~ "25 to 34", 
    Age == "Male - 35-44" ~ "35 to 44", 
    Age == "Male - 45-54" ~ "45 to 54", 
    Age == "Male - 55+" ~ "55 and over",
    Age == "Female - 16-24" ~ "16 to 24", 
    Age == "Female - 25-34" ~ "25 to 34", 
    Age == "Female - 35-44" ~ "35 to 44", 
    Age == "Female - 45-54" ~ "45 to 54", 
    Age == "Female - 55+" ~ "55 and over")) 

nonfatal_inj_age_main <- nonfatal_inj_age_main %>% 
  select("Year", "Age", "Sex", "Value")

# Need to find a future proof way to replace Notes 

nonfatal_inj_age_main$`Year`[nonfatal_inj_age_main$`Year` == "2019/20-2021/22 (Note A, Note B)"] <- "2019/20-2021/22"

nonfatal_inj_age_main <- nonfatal_inj_age_main %>% 
  mutate("Units" = "Rate per 100,000 (3 year average)",
         "Observation status" = "Estimated Value")

nonfatal_inj_age_main <- nonfatal_inj_age_main %>% 
  mutate(Year = case_when(
    Year == "2001/02-2003/04" ~ "2002/03",
    Year == "2002/03-2004/05" ~ "2003/04",
    Year == "2003/04-2005/06" ~ "2004/05",
    Year == "2004/05-2006/07" ~ "2005/06",
    Year == "2005/06-2007/08" ~ "2006/07",
    Year == "2006/07-2008/09" ~ "2007/08",
    Year == "2007/08-2009/10" ~ "2008/09",
    Year == "2008/09-2010/11" ~ "2009/10",
    Year == "2009/10-2011/12" ~ "2010/11",
    Year == "2010/11-2012/13" ~ "2011/12",
    Year == "2011/12-2013/14" ~ "2012/13",
    Year == "2012/13-2014/15" ~ "2013/14",
    Year == "2013/14-2015/16" ~ "2014/15",
    Year == "2014/15-2016/17" ~ "2015/16",
    Year == "2015/16-2017/18" ~ "2016/17",
    Year == "2016/17-2018/19" ~ "2017/18",
    Year == "2017/18-2019/20" ~ "2018/19",
    Year == "2018/19-2020/21" ~ "2019/20",
    Year == "2019/20-2021/22" ~ "2020/21",
    Year == "2019/20-2021/22" ~ "2020/21"))

# non-fatal industry

nonfatal_inj_ind_main <- nonfatal_inj_ind_main[c(6, 8, 12)]

colnames(nonfatal_inj_ind_main) [3] <- "Value"

nonfatal_inj_ind_main <- nonfatal_inj_ind_main[-c(1, 2, 3, 4, 5), ]

nonfatal_inj_ind_main <- nonfatal_inj_ind_main %>% 
  subset(Industry %in% c("Accommodation and food service activities",
         "Administrative and support service activities",
         "Agriculture, forestry and fishing",
         "Arts, entertainment and recreation",
         "Construction",
         "Education",
         "Human health and social work activities",
         "Manufacturing",
         "Other service activities",
         "Professional, scientific and technical activities",
         "Public administration and defence; compulsory social security",
         "Transportation and storage",
         "Wholesale and retail trade; repair of motor vehicles and motorcycles"))

nonfatal_inj_ind_main <- nonfatal_inj_ind_main %>% 
  rename("Industry sector" = "Industry")

nonfatal_inj_ind_main <- nonfatal_inj_ind_main %>% 
  select("Year", "Industry sector", "Value")

# Need to find a future proof way to replace Notes 

nonfatal_inj_ind_main$`Year`[nonfatal_inj_ind_main$`Year` == "2019/20-2021/22 (Note A, Note B)"] <- "2019/20-2021/22"

nonfatal_inj_ind_main <- nonfatal_inj_ind_main %>% 
  mutate("Units" = "Rate per 100,000 (3 year average)",
         "Observation status" = "Estimated Value")

nonfatal_inj_ind_main <- nonfatal_inj_ind_main %>% 
  mutate(Year = case_when(
    Year == "2001/02-2003/04" ~ "2002/03",
    Year == "2002/03-2004/05" ~ "2003/04",
    Year == "2003/04-2005/06" ~ "2004/05",
    Year == "2004/05-2006/07" ~ "2005/06",
    Year == "2005/06-2007/08" ~ "2006/07",
    Year == "2006/07-2008/09" ~ "2007/08",
    Year == "2007/08-2009/10" ~ "2008/09",
    Year == "2008/09-2010/11" ~ "2009/10",
    Year == "2009/10-2011/12" ~ "2010/11",
    Year == "2010/11-2012/13" ~ "2011/12",
    Year == "2011/12-2013/14" ~ "2012/13",
    Year == "2012/13-2014/15" ~ "2013/14",
    Year == "2013/14-2015/16" ~ "2014/15",
    Year == "2014/15-2016/17" ~ "2015/16",
    Year == "2015/16-2017/18" ~ "2016/17",
    Year == "2016/17-2018/19" ~ "2017/18",
    Year == "2017/18-2019/20" ~ "2018/19",
    Year == "2018/19-2020/21" ~ "2019/20",
    Year == "2019/20-2021/22" ~ "2020/21",
    Year == "2019/20-2021/22" ~ "2020/21"))

# non-fatal occ

nonfatal_inj_occ_main <- nonfatal_inj_occ_main[c(6, 8, 12)]

colnames(nonfatal_inj_occ_main) [3] <- "Value"

nonfatal_inj_occ_main <- nonfatal_inj_occ_main[-c(1, 2, 3, 4, 5), ]


nonfatal_inj_occ_main <- nonfatal_inj_occ_main %>% 
  subset(Occupation %in% c("Administrative and secretarial occupations",
                         "Associate professional and technical occupations",
                         "Caring, leisure and other service occupations",
                         "Elementary occupations",
                         "Managers, directors and senior officials",
                         "Education",
                         "Process, plant and machine operatives",
                         "Professional occupations",
                         "Sales and customer service occupations",
                         "Skilled trades occupations"))

nonfatal_inj_occ_main <- nonfatal_inj_occ_main %>% 
  select("Year", "Occupation", "Value")

nonfatal_inj_occ_main <- nonfatal_inj_occ_main %>% 
  mutate("Units" = "Rate per 100,000 (3 year average)",
         "Observation status" = "Estimated Value")

nonfatal_inj_occ_main <- nonfatal_inj_occ_main %>%
  mutate(Year = case_when(
    Year == "2001/02-2003/04" ~ "2002/03",
    Year == "2002/03-2004/05" ~ "2003/04",
    Year == "2003/04-2005/06" ~ "2004/05",
    Year == "2004/05-2006/07" ~ "2005/06",
    Year == "2005/06-2007/08" ~ "2006/07",
    Year == "2006/07-2008/09" ~ "2007/08",
    Year == "2007/08-2009/10" ~ "2008/09",
    Year == "2008/09-2010/11" ~ "2009/10",
    Year == "2009/10-2011/12" ~ "2010/11",
    Year == "2010/11-2012/13" ~ "2011/12",
    Year == "2011/12-2013/14" ~ "2012/13",
    Year == "2012/13-2014/15" ~ "2013/14",
    Year == "2013/14-2015/16" ~ "2014/15",
    Year == "2014/15-2016/17" ~ "2015/16",
    Year == "2015/16-2017/18" ~ "2016/17",
    Year == "2016/17-2018/19" ~ "2017/18",
    Year == "2017/18-2019/20" ~ "2018/19",
    Year == "2018/19-2020/21" ~ "2019/20",
    Year == "2019/20-2021/22" ~ "2020/21",
    Year == "2019/20-2021/22" ~ "2020/21"))

# Then join non-fatal data

nonfatal_joined_data <- full_join(nonfatal_inj_summary_main, 
                                  nonfatal_inj_region_main, 
                                  by = c("Year", 
                                          "Value",
                                          "Units",
                                          "Observation status")) 


nonfatal_joined_data <- full_join(nonfatal_joined_data, 
                                  nonfatal_inj_age_main, 
                                  by = c("Year",
                                         "Value",
                                         "Units",
                                         "Observation status"))  

nonfatal_joined_data <- full_join(nonfatal_joined_data, 
                                  nonfatal_inj_ind_main, 
                                  by = c("Year",
                                         "Value",
                                         "Units",
                                         "Observation status")) 

nonfatal_joined_data <- full_join(nonfatal_joined_data, 
                                  nonfatal_inj_occ_main, 
                                  by = c("Year",
                                         "Value",
                                         "Units",
                                         "Observation status")) 

nonfatal_joined_data <- nonfatal_joined_data %>% 
  replace(is.na(.), "")

nonfatal_joined_data <- nonfatal_joined_data %>% 
  mutate("Series" = "Non-fatal injury",
         "Unit multiplier" =  "Units")
  
  
nonfatal_joined_data <- nonfatal_joined_data %>% 
  select("Year", 
         "Series", 
         "Age", 
         "Sex", 
         "Country", 
         "Region", 
         "Industry sector", 
         "Occupation", 
         "Units", 
         "Unit multiplier", 
         "Observation status", 
         "Value")

csv_output <- full_join(fatal_joined_data, 
                        nonfatal_joined_data)



